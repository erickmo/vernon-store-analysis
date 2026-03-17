"""
Custom exception hierarchy untuk aplikasi.
Semua exception domain harus inherit dari AppException.
"""


class AppException(Exception):
    """Base exception untuk semua error aplikasi."""

    def __init__(self, message: str, status_code: int = 500):
        super().__init__(message)
        self.message = message
        self.status_code = status_code


class NotFoundException(AppException):
    """Resource tidak ditemukan."""

    def __init__(self, resource: str = "Resource"):
        super().__init__(f"{resource} tidak ditemukan", status_code=404)


class AlreadyExistsException(AppException):
    """Resource sudah ada (conflict)."""

    def __init__(self, resource: str = "Resource"):
        super().__init__(f"{resource} sudah ada", status_code=409)


class ValidationException(AppException):
    """Input validation gagal."""

    def __init__(self, message: str):
        super().__init__(message, status_code=400)


class UnauthorizedException(AppException):
    """User tidak terautentikasi."""

    def __init__(self, message: str = "Tidak terautentikasi"):
        super().__init__(message, status_code=401)


class ForbiddenException(AppException):
    """User tidak punya akses."""

    def __init__(self, message: str = "Akses ditolak"):
        super().__init__(message, status_code=403)


class DatabaseException(AppException):
    """Error pada operasi database."""

    def __init__(self, message: str = "Database error"):
        super().__init__(message, status_code=500)
