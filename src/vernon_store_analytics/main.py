"""
Entry point aplikasi FastAPI vernon_store_analytics.
"""

from contextlib import asynccontextmanager

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from .api.v1.middleware import RequestLoggingMiddleware
from .core.config import get_settings
from .core.database import engine
from .core.exceptions import AppException
from .core.logger import get_logger, setup_logging

settings = get_settings()
logger = get_logger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Lifecycle handler — startup dan shutdown."""
    setup_logging()
    logger.info("starting up", app=settings.app_name, env=settings.app_env)
    yield
    # Stop all CCTV streams
    from .services.stream.stream_manager import StreamManager
    stream_manager = StreamManager.get_instance()
    await stream_manager.stop_all()
    await engine.dispose()
    logger.info("shutdown complete")


app = FastAPI(
    title=settings.app_name,
    version=settings.app_version,
    description="Backend engine untuk CCTV store analytics — traffic analysis, person identification, mood detection, dan shoplifting detection.",
    docs_url="/docs" if not settings.is_production else None,
    redoc_url="/redoc" if not settings.is_production else None,
    lifespan=lifespan,
)

# ── Middleware ─────────────────────────────────────────────────
app.add_middleware(RequestLoggingMiddleware)
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ── Exception Handlers ─────────────────────────────────────────
@app.exception_handler(AppException)
async def app_exception_handler(request: Request, exc: AppException) -> JSONResponse:
    """Handler untuk semua AppException — return response yang konsisten."""
    return JSONResponse(
        status_code=exc.status_code,
        content={"success": False, "error": exc.message},
    )


@app.exception_handler(Exception)
async def generic_exception_handler(request: Request, exc: Exception) -> JSONResponse:
    """Handler untuk unhandled exception — jangan ekspos detail ke client."""
    logger.error("unhandled exception", exc_info=exc)
    return JSONResponse(
        status_code=500,
        content={"success": False, "error": "Terjadi kesalahan internal"},
    )


# ── Routes ─────────────────────────────────────────────────────
@app.get("/health")
async def health_check():
    """Health check endpoint untuk monitoring."""
    return {
        "status": "ok",
        "service": settings.app_name,
        "version": settings.app_version,
    }


# ── Register Routers ──────────────────────────────────────────
from .api.v1 import (
    alert_router,
    analytics_router,
    auth_router,
    camera_router,
    statistics_router,
    store_router,
    stream_router,
    traffic_router,
    visitor_router,
)

app.include_router(auth_router.router, prefix="/api/v1")
app.include_router(store_router.router, prefix="/api/v1")
app.include_router(camera_router.router, prefix="/api/v1")
app.include_router(visitor_router.router, prefix="/api/v1")
app.include_router(traffic_router.router, prefix="/api/v1")
app.include_router(alert_router.router, prefix="/api/v1")
app.include_router(analytics_router.router, prefix="/api/v1")
app.include_router(statistics_router.router, prefix="/api/v1")
app.include_router(stream_router.router, prefix="/api/v1")

# Simulate router — hanya di development
if not settings.is_production:
    from .api.v1 import simulate_router
    app.include_router(simulate_router.router, prefix="/api/v1")
