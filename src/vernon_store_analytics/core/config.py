"""
Konfigurasi aplikasi dari environment variables.
Semua config wajib dari env — tidak ada hardcode.
"""

from functools import lru_cache
from typing import Literal

from pydantic import Field, field_validator
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """
    Konfigurasi aplikasi.
    Semua nilai diambil dari environment variable atau file .env.
    """

    # App
    app_name: str = "vernon_store_analytics"
    app_env: Literal["development", "staging", "production"] = "development"
    app_version: str = "1.0.0"
    debug: bool = False
    secret_key: str

    # Server
    host: str = "0.0.0.0"
    port: int = 8000
    workers: int = 1

    # Database
    database_url: str
    db_pool_size: int = 10
    db_max_overflow: int = 20
    db_pool_timeout: int = 30
    db_echo: bool = False

    # JWT
    jwt_algorithm: str = "HS256"
    access_token_expire_minutes: int = 15
    refresh_token_expire_days: int = 7

    # CORS
    cors_origins: list[str] = ["*"]

    # Logging
    log_level: str = "INFO"
    log_format: Literal["json", "console"] = "console"

    # CCTV / Video Stream
    cctv_stream_urls: list[str] = []
    cctv_frame_interval: int = 5

    # Shoplifting Detection
    shoplifting_threshold: float = 0.75
    shoplifting_notification_cooldown_seconds: int = 300

    # Notification
    notification_webhook_url: str = ""
    notification_email_to: str = ""

    @field_validator("secret_key")
    @classmethod
    def secret_key_must_be_strong(cls, v: str) -> str:
        """Secret key minimal 32 karakter."""
        if len(v) < 32:
            raise ValueError("SECRET_KEY harus minimal 32 karakter")
        return v

    @property
    def is_production(self) -> bool:
        """True jika berjalan di environment production."""
        return self.app_env == "production"

    model_config = {"env_file": ".env", "case_sensitive": False, "extra": "ignore"}


@lru_cache
def get_settings() -> Settings:
    """Return cached Settings instance. Dipanggil sebagai dependency."""
    return Settings()
