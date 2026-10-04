"""Transport layer for meuapp_client.

See AGENTS.md section "Arquitetura da biblioteca".
"""

from __future__ import annotations

import asyncio
import logging
import time
from typing import Any, Self

import httpx

from .config import Settings
from .errors import NetworkError

logger = logging.getLogger(__name__)


def _mask_sensitive_headers(headers: dict[str, Any]) -> dict[str, Any]:
    """Return a copy of headers with sensitive values masked."""
    masked = headers.copy()
    sensitive_headers = {"authorization", "cookie", "x-api-key"}
    for key in list(masked.keys()):
        if key.lower() in sensitive_headers:
            masked[key] = "[REDACTED]"
    return masked


class BaseTransport:
    """Base transport with common functionality."""

    def __init__(self, settings: Settings) -> None:
        self.settings = settings
        self._rate_limit_interval = 1.0 / settings.max_rps if settings.max_rps > 0 else 0
        self._last_request_time = 0.0

    def _enforce_rate_limit(self) -> None:
        """Simple rate limiter: wait if needed to not exceed max_rps."""
        if self._rate_limit_interval <= 0:
            return

        elapsed = time.time() - self._last_request_time
        if elapsed < self._rate_limit_interval:
            time.sleep(self._rate_limit_interval - elapsed)
        self._last_request_time = time.time()

    def _prepare_request(
        self,
        method: str,
        url: str,
        *,
        headers: dict[str, Any] | None = None,
        **kwargs: Any,
    ) -> dict[str, Any]:
        """Prepare request arguments, merging with settings and applying rate limit."""
        self._enforce_rate_limit()

        # Merge headers: settings headers (none for now) + provided headers
        request_headers = {}
        if headers:
            request_headers.update(headers)

        # Log request (without sensitive data)
        logger.debug(
            "Making %s request to %s",
            method,
            url,
            extra={"headers": _mask_sensitive_headers(request_headers)},
        )

        return {
            "method": method,
            "url": url,
            "headers": request_headers,
            **kwargs,
        }


class Transport(BaseTransport):
    """Synchronous HTTP client with retry and rate limiting."""

    def __init__(self, settings: Settings) -> None:
        super().__init__(settings)
        self._client = httpx.Client(
            base_url=settings.base_url,
            timeout=settings.timeout,
            follow_redirects=True,
        )

    def request(
        self,
        method: str,
        url: str,
        *,
        headers: dict[str, Any] | None = None,
        **kwargs: Any,
    ) -> httpx.Response:
        """Make a synchronous HTTP request with retry on network errors and 5xx."""
        request_kwargs = self._prepare_request(method, url, headers=headers, **kwargs)

        last_exception: Exception | None = None
        for attempt in range(self.settings.retries + 1):
            try:
                response = self._client.request(**request_kwargs)
                # Retry on 5xx status codes
                if 500 <= response.status_code < 600 and attempt < self.settings.retries:
                    logger.warning(
                        "Received %s status, retrying (%d/%d)...",
                        response.status_code,
                        attempt + 1,
                        self.settings.retries,
                    )
                    time.sleep(0.5 * (attempt + 1))  # simple backoff
                    continue
                # If we get a 5xx and no retries left, or any other status, we return it.
                # But if it's 5xx and we are out of retries, we should raise an error.
                if 500 <= response.status_code < 600:
                    raise NetworkError(
                        f"Request failed with status {response.status_code} after {self.settings.retries + 1} attempts"
                    )
                return response
            except (httpx.RequestError, httpx.HTTPStatusError) as exc:
                last_exception = exc
                if attempt < self.settings.retries:
                    logger.warning(
                        "Request failed (%s), retrying (%d/%d)...",
                        exc,
                        attempt + 1,
                        self.settings.retries,
                    )
                    time.sleep(0.5 * (attempt + 1))  # simple backoff
                else:
                    logger.error("Request failed after %d attempts: %s", self.settings.retries + 1, exc)
        # If we exhausted retries due to exceptions, raise a NetworkError
        raise NetworkError(f"Request failed after {self.settings.retries + 1} attempts") from last_exception

    def __enter__(self) -> Self:
        return self

    def __exit__(self, *args: object) -> None:
        self.close()

    def close(self) -> None:
        """Close the underlying HTTP client."""
        self._client.close()


class AsyncTransport(BaseTransport):
    """Asynchronous HTTP client with retry and rate limiting."""

    def __init__(self, settings: Settings) -> None:
        super().__init__(settings)
        self._client = httpx.AsyncClient(
            base_url=settings.base_url,
            timeout=settings.timeout,
            follow_redirects=True,
        )

    async def request(
        self,
        method: str,
        url: str,
        *,
        headers: dict[str, Any] | None = None,
        **kwargs: Any,
    ) -> httpx.Response:
        """Make an asynchronous HTTP request with retry on network errors and 5xx."""
        request_kwargs = self._prepare_request(method, url, headers=headers, **kwargs)

        last_exception: Exception | None = None
        for attempt in range(self.settings.retries + 1):
            try:
                response = await self._client.request(**request_kwargs)
                # Retry on 5xx status codes
                if 500 <= response.status_code < 600 and attempt < self.settings.retries:
                    logger.warning(
                        "Received %s status, retrying (%d/%d)...",
                        response.status_code,
                        attempt + 1,
                        self.settings.retries,
                    )
                    await asyncio.sleep(0.5 * (attempt + 1))  # simple backoff
                    continue
                # If we get a 5xx and no retries left, raise NetworkError
                if 500 <= response.status_code < 600:
                    raise NetworkError(
                        f"Request failed with status {response.status_code} after {self.settings.retries + 1} attempts"
                    )
                return response
            except (httpx.RequestError, httpx.HTTPStatusError) as exc:
                last_exception = exc
                if attempt < self.settings.retries:
                    logger.warning(
                        "Request failed (%s), retrying (%d/%d)...",
                        exc,
                        attempt + 1,
                        self.settings.retries,
                    )
                    await asyncio.sleep(0.5 * (attempt + 1))  # simple backoff
                else:
                    logger.error("Request failed after %d attempts: %s", self.settings.retries + 1, exc)
        # If we exhausted retries due to exceptions, raise a NetworkError
        raise NetworkError(f"Request failed after {self.settings.retries + 1} attempts") from last_exception

    async def __aenter__(self) -> Self:
        return self

    async def __aexit__(self, *args: object) -> None:
        await self.aclose()

    async def aclose(self) -> None:
        """Close the underlying HTTP client."""
        await self._client.aclose()