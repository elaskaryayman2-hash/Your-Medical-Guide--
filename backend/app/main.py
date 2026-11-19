import os
from contextlib import asynccontextmanager
from typing import Optional
from uuid import UUID

from fastapi import FastAPI, HTTPException, Query
from pydantic import BaseModel, Field
from sqlalchemy import create_engine, text
from sqlalchemy.exc import SQLAlchemyError

DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql+psycopg://medicalguide:change-this-password@localhost:5432/medicalguide",
)
engine = create_engine(DATABASE_URL, pool_pre_ping=True)

class ProviderSubmission(BaseModel):
    provider_type: str = Field(pattern="^(hospital|clinic|doctor)$")
    name: str = Field(min_length=2, max_length=200)
    country_code: str = Field(min_length=2, max_length=2)
    city: str = Field(min_length=1, max_length=120)
    address: str = Field(min_length=3, max_length=500)
    phone_e164: Optional[str] = Field(default=None, max_length=30)
    website_url: Optional[str] = Field(default=None, max_length=500)
    latitude: float = Field(ge=-90, le=90)
    longitude: float = Field(ge=-180, le=180)
    source_name: Optional[str] = Field(default=None, max_length=200)
    source_url: Optional[str] = Field(default=None, max_length=500)

@asynccontextmanager
async def lifespan(app: FastAPI):
    yield

app = FastAPI(
    title="Your Medical Guide API",
    version="0.3.0",
    description="Healthcare directory API. Only verified providers are public.",
    lifespan=lifespan,
)

@app.get("/health")
def health():
    try:
        with engine.connect() as conn:
            conn.execute(text("SELECT 1"))
        return {"status": "ok", "database": "connected", "version": "0.3.0"}
    except SQLAlchemyError:
        raise HTTPException(status_code=503, detail="Database is unavailable")

@app.get("/v1/providers")
def list_providers(
    latitude: Optional[float] = Query(default=None, ge=-90, le=90),
    longitude: Optional[float] = Query(default=None, ge=-180, le=180),
    radius_km: float = Query(default=30, ge=1, le=200),
    provider_type: Optional[str] = Query(default=None, pattern="^(hospital|clinic|doctor)$"),
    q: Optional[str] = Query(default=None, max_length=120),
    limit: int = Query(default=50, ge=1, le=100),
):
    if (latitude is None) != (longitude is None):
        raise HTTPException(status_code=422, detail="latitude and longitude must be supplied together")
    sql = """
      SELECT id, provider_type, name, city, address, phone_e164, website_url,
             ST_Y(location::geometry) AS latitude,
             ST_X(location::geometry) AS longitude,
             CASE WHEN :latitude IS NULL THEN NULL ELSE
               ST_Distance(location, ST_SetSRID(ST_MakePoint(:longitude,:latitude),4326)::geography)/1000 END AS distance_km
      FROM providers
      WHERE verification_status = 'verified' AND location IS NOT NULL
        AND (:provider_type IS NULL OR provider_type = :provider_type)
        AND (:q IS NULL OR name ILIKE '%' || :q || '%' OR city ILIKE '%' || :q || '%')
        AND (:latitude IS NULL OR ST_DWithin(location,
             ST_SetSRID(ST_MakePoint(:longitude,:latitude),4326)::geography, :radius_m))
      ORDER BY CASE WHEN :latitude IS NULL THEN 0 ELSE distance_km END NULLS LAST, name
      LIMIT :limit
    """
    params = {"latitude": latitude, "longitude": longitude, "radius_m": radius_km * 1000,
              "provider_type": provider_type, "q": q, "limit": limit}
    try:
        with engine.connect() as conn:
            rows = conn.execute(text(sql), params).mappings().all()
        return {"items": [dict(row) for row in rows], "count": len(rows),
                "only_verified": True, "coverage_note": "Coverage depends on verified data sources in each country."}
    except SQLAlchemyError:
        raise HTTPException(status_code=503, detail="Provider search is temporarily unavailable")

@app.post("/v1/provider-submissions", status_code=202)
def submit_provider(submission: ProviderSubmission):
    sql = text("""
      INSERT INTO provider_submissions
      (provider_type, name, country_code, city, address, phone_e164, website_url,
       location, source_name, source_url, status)
      VALUES (:provider_type,:name,:country_code,:city,:address,:phone_e164,:website_url,
       ST_SetSRID(ST_MakePoint(:longitude,:latitude),4326)::geography,
       :source_name,:source_url,'pending_review') RETURNING id
    """)
    try:
        with engine.begin() as conn:
            row = conn.execute(sql, submission.model_dump()).mappings().one()
        return {"id": str(row["id"]), "status": "pending_review",
                "message": "Submitted for review. It will not appear publicly before approval."}
    except SQLAlchemyError:
        raise HTTPException(status_code=503, detail="Could not save submission")
