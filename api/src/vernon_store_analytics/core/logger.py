"""
Konfigurasi structured logging menggunakan structlog.
"""

import logging
import sys

import structlog

from .config import get_settings


def setup_logging() -> None:
    """
    Inisialisasi logging. Dipanggil satu kali di startup aplikasi.

    Format JSON untuk production, format console yang mudah dibaca untuk development.
    """
    settings = get_settings()
    log_level = getattr(logging, settings.log_level.upper(), logging.INFO)

    shared_processors = [
        structlog.contextvars.merge_contextvars,
        structlog.processors.add_log_level,
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.CallsiteParameterAdder(
            [structlog.processors.CallsiteParameter.MODULE],
        ),
    ]

    if settings.log_format == "json":
        processors = shared_processors + [structlog.processors.JSONRenderer()]
    else:
        processors = shared_processors + [
            structlog.dev.ConsoleRenderer(colors=True)
        ]

    structlog.configure(
        processors=processors,
        wrapper_class=structlog.make_filtering_bound_logger(log_level),
        context_class=dict,
        logger_factory=structlog.PrintLoggerFactory(sys.stdout),
        cache_logger_on_first_use=True,
    )

    logging.basicConfig(
        format="%(message)s",
        stream=sys.stdout,
        level=log_level,
    )


def get_logger(name: str = __name__):
    """Mendapatkan logger instance dengan nama tertentu."""
    return structlog.get_logger(name)
