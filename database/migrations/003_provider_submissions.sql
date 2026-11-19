CREATE TABLE IF NOT EXISTS provider_submissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  provider_type TEXT NOT NULL CHECK (provider_type IN ('hospital','clinic','doctor')),
  name TEXT NOT NULL,
  country_code CHAR(2) NOT NULL,
  city TEXT NOT NULL,
  address TEXT NOT NULL,
  phone_e164 TEXT,
  website_url TEXT,
  location GEOGRAPHY(POINT,4326) NOT NULL,
  source_name TEXT,
  source_url TEXT,
  status TEXT NOT NULL DEFAULT 'pending_review'
    CHECK (status IN ('pending_review','approved','rejected')),
  submitted_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  reviewed_at TIMESTAMPTZ,
  reviewer_notes TEXT
);
CREATE INDEX IF NOT EXISTS provider_submissions_status_idx ON provider_submissions(status);
