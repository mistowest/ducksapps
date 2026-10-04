"""Configuration for meuapp_client.

See AGENTS.md section "Arquitetura da biblioteca" and Doc/PROTOCOL.md.
"""

import os
from dataclasses import dataclass, field


@dataclass
class Settings:
    """Base configuration for the client.

    All values can be set via environment variables with prefix MEUAPP_.
    """
    base_url: str | None = field(
        default=None,
        metadata={"env": "MEUAPP_BASE_URL"}
    )
    timeout: float = field(
        default=30.0,
        metadata={"env": "MEUAPP_TIMEOUT"}
    )
    user_agent: str | None = field(
        default=None,
        metadata={"env": "MEUAPP_USER_AGENT"}
    )
    app_version: str | None = field(
        default=None,
        metadata={"env": "MEUAPP_APP_VERSION"}
    )
    max_rps: float = field(
        default=1.0,
        metadata={"env": "MEUAPP_MAX_RPS"}
    )
    retries: int = field(
        default=3,
        metadata={"env": "MEUAPP_RETRIES"}
    )

    def __post_init__(self) -> None:
        # Load from environment variables if not set
        for field_name in self.__dataclass_fields__:
            env_var = f"MEUAPP_{field_name.upper()}"
            value = os.getenv(env_var)
            if value is not None:
                # Try to convert to the expected type
                current_value = getattr(self, field_name)
                if isinstance(current_value, bool):
                    setattr(self, field_name, value.lower() in ("true", "1", "yes"))
                elif isinstance(current_value, int):
                    setattr(self, field_name, int(value))
                elif isinstance(current_value, float):
                    setattr(self, field_name, float(value))
                else:
                    setattr(self, field_name, value)