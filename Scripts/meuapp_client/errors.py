"""Error hierarchy for meuapp_client.

See AGENTS.md section "Arquitetura da biblioteca".
"""

class MeuappError(Exception):
    """Base exception for all meuapp_client errors."""


class NetworkError(MeuappError):
    """Network-related errors (e.g., connection, timeout)."""


class AuthError(MeuappError):
    """Authentication-related errors (e.g., invalid token, login failed)."""


class RateLimitError(MeuappError):
    """Rate limit exceeded error."""


class ApiError(MeuappError):
    """API returned an error response.

    Attributes:
        status: HTTP status code.
        code: Application-specific error code.
        message: Human-readable error message.
    """

    def __init__(self, status: int, code: str, message: str) -> None:
        self.status = status
        self.code = code
        self.message = message
        super().__init__(f"API error {status} {code}: {message}")