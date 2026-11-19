-- PostgreSQL + PostGIS starter schema.
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE countries (
  code CHAR(2) PRIMARY KEY,
  name_en TEXT NOT NULL,
  name_local TEXT,
  default_phone_prefix TEXT,
  emergency_numbers JSONB NOT NULL DEFAULT '{}'::jsonb
);

CREATE TABLE providers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  provider_type TEXT NOT NULL CHECK (provider_type IN ('hospital','clinic','doctor')),
  name TEXT NOT NULL,
  description TEXT,
  country_code CHAR(2) REFERENCES countries(code),
  city TEXT,
  address TEXT,
  phone_e164 TEXT,
  website_url TEXT,
  location GEOGRAPHY(POINT, 4326),
  timezone TEXT,
  verification_status TEXT NOT NULL DEFAULT 'unverified'
    CHECK (verification_status IN ('unverified','pending','verified','rejected')),
  source_name TEXT,
  source_url TEXT,
  last_verified_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX providers_location_gix ON providers USING GIST(location);
CREATE INDEX providers_country_city_idx ON providers(country_code, city);
CREATE INDEX providers_type_idx ON providers(provider_type);

CREATE TABLE provider_translations (
  provider_id UUID NOT NULL REFERENCES providers(id) ON DELETE CASCADE,
  language_code VARCHAR(10) NOT NULL,
  display_name TEXT,
  description TEXT,
  address TEXT,
  PRIMARY KEY(provider_id, language_code)
);

CREATE TABLE specialties (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT UNIQUE NOT NULL
);

CREATE TABLE provider_specialties (
  provider_id UUID REFERENCES providers(id) ON DELETE CASCADE,
  specialty_id UUID REFERENCES specialties(id) ON DELETE CASCADE,
  PRIMARY KEY(provider_id, specialty_id)
);

CREATE TABLE opening_hours (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  provider_id UUID NOT NULL REFERENCES providers(id) ON DELETE CASCADE,
  weekday SMALLINT NOT NULL CHECK (weekday BETWEEN 0 AND 6),
  opens_at TIME,
  closes_at TIME,
  is_closed BOOLEAN NOT NULL DEFAULT false,
  valid_from DATE,
  valid_until DATE
);

CREATE TABLE appointments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  provider_id UUID NOT NULL REFERENCES providers(id),
  starts_at TIMESTAMPTZ NOT NULL,
  ends_at TIMESTAMPTZ NOT NULL,
  status TEXT NOT NULL DEFAULT 'available'
    CHECK (status IN ('available','booked','blocked')),
  booking_url TEXT,
  source_updated_at TIMESTAMPTZ
);

-- Do not store patient medical records in the directory database.
-- Add audit logs, row-level authorization, retention and consent policies
-- before production deployment.
