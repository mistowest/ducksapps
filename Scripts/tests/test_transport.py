"""Tests for transport layer."""


import httpx
import pytest
import respx
from meuapp_client.config import Settings
from meuapp_client.errors import NetworkError
from meuapp_client.transport import AsyncTransport, Transport


@pytest.fixture
def settings():
    return Settings(base_url="https://example.com", timeout=5.0, retries=2, max_rps=10.0)


def test_transport_retry_success_after_503(settings):
    """Test that retry works: two 503 then a 200 succeeds."""
    with respx.mock() as respx_mock:
        # Mock three calls: first two return 503, third returns 200
        route = respx_mock.post("https://example.com/test").mock(
            side_effect=[
                httpx.Response(503),
                httpx.Response(503),
                httpx.Response(200, text="success"),
            ]
        )

        with Transport(settings) as transport:
            response = transport.request("POST", "/test")

        assert response.status_code == 200
        assert response.text == "success"
        assert route.call_count == 3


def test_transport_retry_exhausted(settings):
    """Test that after retries are exhausted, NetworkError is raised."""
    with respx.mock() as respx_mock:
        # Mock to always return 503
        respx_mock.post("https://example.com/test").mock(
            return_value=httpx.Response(503)
        )

        with Transport(settings) as transport, pytest.raises(NetworkError):
            transport.request("POST", "/test")


def test_transport_logs_do_not_leak_authorization(settings, caplog):
    """Test that logs never expose the Authorization header value."""
    with respx.mock() as respx_mock:
        respx_mock.post("https://example.com/test").mock(
            return_value=httpx.Response(200, text="ok")
        )

        with Transport(settings) as transport:
            # Make a request with an Authorization header
            transport.request(
                "POST",
                "/test",
                headers={"Authorization": "Bearer secret-token"},
            )

        # Check that no log record contains the secret token
        for record in caplog.records:
            assert "secret-token" not in record.getMessage()
            # Also check that the header is redacted in the extra data
            if "headers" in record.__dict__:
                headers = record.__dict__["headers"]
                # The headers dict in the extra should have redacted Authorization
                assert headers.get("Authorization") == "[REDACTED]"


@pytest.mark.asyncio
async def test_async_transport_retry_success_after_503(settings):
    """Test async transport retry: two 503 then a 200 succeeds."""
    with respx.mock() as respx_mock:
        route = respx_mock.post("https://example.com/test").mock(
            side_effect=[
                httpx.Response(503),
                httpx.Response(503),
                httpx.Response(200, text="success"),
            ]
        )

        async with AsyncTransport(settings) as transport:
            response = await transport.request("POST", "/test")

        assert response.status_code == 200
        assert response.text == "success"
        assert route.call_count == 3


@pytest.mark.asyncio
async def test_async_transport_logs_do_not_leak_authorization(settings, caplog):
    """Test that async transport logs never expose the Authorization header value."""
    with respx.mock() as respx_mock:
        respx_mock.post("https://example.com/test").mock(
            return_value=httpx.Response(200, text="ok")
        )

        async with AsyncTransport(settings) as transport:
            await transport.request(
                "POST",
                "/test",
                headers={"Authorization": "Bearer secret-token"},
            )

        # Check that no log record contains the secret token
        for record in caplog.records:
            assert "secret-token" not in record.getMessage()
            if "headers" in record.__dict__:
                headers = record.__dict__["headers"]
                assert headers.get("Authorization") == "[REDACTED]"