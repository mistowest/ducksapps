"""Authentication utilities for meuapp_client.

See AGENTS.md section "Arquitetura da biblioteca" and Doc/analysis/03-auth.md.
"""

from __future__ import annotations

from .config import Settings
from .transport import AsyncTransport, Transport

# Placeholder for future implementation.
# The actual authentication flow (login, refresh, etc.) should be implemented
# based on the documentation in Doc/analysis/03-auth.md and any specific
# task that requests authentication features.

class Auth:
    """Handles authentication state and token refresh."""

    def __init__(
        self,
        settings: Settings,
        transport: Transport | None = None,
        async_transport: AsyncTransport | None = None,
    ) -> None:
        self.settings = settings
        self._transport = transport
        self._async_transport = async_transport
        self._access_token: str | None = None
        self._refresh_token: str | None = None

    # Placeholder methods
    def login(self, username: str, password: str) -> None:
        """Log in with username and password.
        Not implemented yet; see Doc/analysis/03-auth.md for details.
        """
        raise NotImplementedError("Login not implemented")

    def refresh(self) -> None:
        """Refresh the access token using the refresh token.
        Not implemented yet; see Doc/analysis/03-auth.md for details.
        """
        raise NotImplementedError("Refresh not implemented")

    def get_access_token(self) -> str | None:
        """Return the current access token."""
        return self._access_token

    def is_authenticated(self) -> bool:
        """Return True if we have an access token."""
        return self._access_token is not None

    def clear(self) -> None:
        """Clear stored tokens."""
        self._access_token = None
        self._refresh_token = None

# Convenience functions for sync and async clients could be added later.