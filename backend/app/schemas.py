from typing import Literal
from pydantic import BaseModel, Field, HttpUrl

ProviderType = Literal["hospital", "clinic", "doctor"]

class ProviderSearchFilters(BaseModel):
    query: str | None = None
    country_code: str | None = Field(default=None, min_length=2, max_length=2)
    city: str | None = None
    provider_type: ProviderType | None = None
    latitude: float | None = Field(default=None, ge=-90, le=90)
    longitude: float | None = Field(default=None, ge=-180, le=180)
    radius_km: float = Field(default=10, gt=0, le=200)
    language: Literal["ar", "en"] = "ar"

class ProviderSubmission(BaseModel):
    provider_type: ProviderType
    name: str = Field(min_length=2, max_length=200)
    country_code: str = Field(min_length=2, max_length=2)
    city: str = Field(min_length=1, max_length=120)
    address: str = Field(min_length=3, max_length=500)
    phone_e164: str | None = Field(default=None, max_length=20)
    website_url: HttpUrl | None = None
    description: str | None = Field(default=None, max_length=3000)
    # Submitted records must enter moderation; never publish directly.
