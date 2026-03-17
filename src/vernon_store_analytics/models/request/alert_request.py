"""Pydantic request models untuk ShopliftingAlert."""

from pydantic import BaseModel, Field


class AlertResolveRequest(BaseModel):
    """Request untuk resolve shoplifting alert."""

    resolved_note: str | None = Field(None, max_length=1000)
