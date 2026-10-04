"""Tests for configuration."""


import pytest
from meuapp_client.config import Settings


def test_settings_defaults():
    """Test that default values are set correctly."""
    settings = Settings()
    assert settings.base_url is None
    assert settings.timeout == 30.0
    assert settings.user_agent is None
    assert settings.app_version is None
    assert settings.max_rps == 1.0
    assert settings.retries == 3


def test_settings_from_env(monkeypatch):
    """Test that settings can be overridden by environment variables."""
    monkeypatch.setenv("MEUAPP_BASE_URL", "https://example.com")
    monkeypatch.setenv("MEUAPP_TIMEOUT", "5.0")
    monkeypatch.setenv("MEUAPP_USER_AGENT", "test-agent")
    monkeypatch.setenv("MEUAPP_APP_VERSION", "1.0.0")
    monkeypatch.setenv("MEUAPP_MAX_RPS", "2.0")
    monkeypatch.setenv("MEUAPP_RETRIES", "5")

    settings = Settings()
    assert settings.base_url == "https://example.com"
    assert settings.timeout == 5.0
    assert settings.user_agent == "test-agent"
    assert settings.app_version == "1.0.0"
    assert settings.max_rps == 2.0
    assert settings.retries == 5


def test_settings_env_types(monkeypatch):
    """Test that environment variables are converted to correct types."""
    monkeypatch.setenv("MEUAPP_TIMEOUT", "not a float")
    # Should not raise, but keep default if conversion fails? Actually, we expect it to raise.
    # However, our current implementation will raise ValueError when trying to convert.
    # Let's test that it raises.
    with pytest.raises(ValueError):
        Settings()

    # Reset and test with valid values
    monkeypatch.delenv("MEUAPP_TIMEOUT", raising=False)
    monkeypatch.setenv("MEUAPP_TIMEOUT", "10.5")
    settings = Settings()
    assert settings.timeout == 10.5

    # Test integer conversion
    monkeypatch.setenv("MEUAPP_RETRIES", "7")
    settings = Settings()
    assert settings.retries == 7

    # Test float conversion for max_rps
    monkeypatch.setenv("MEUAPP_MAX_RPS", "0.5")
    settings = Settings()
    assert settings.max_rps == 0.5

    # Test boolean? We don't have boolean fields, but if we did, we'd test.