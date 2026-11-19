-- Provider onboarding and moderation extension.
CREATE TABLE provider_accounts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  auth_subject TEXT UNIQUE NOT NULL,
  account_type TEXT NOT NULL CHECK (account_type IN ('individual','organization')),
  display_name TEXT NOT NULL,
  email TEXT,
  phone_e164 TEXT,
  status TEXT NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending','active','suspended','rejected')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE provider_claims (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  provider_id UUID NOT NULL REFERENCES providers(id),
  account_id UUID NOT NULL REFERENCES provider_accounts(id),
  claim_note TEXT,
  status TEXT NOT NULL DEFAULT 'pending_review'
    CHECK (status IN ('pending_review','approved','rejected','needs_changes')),
  reviewed_by TEXT,
  reviewed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE provider_change_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  provider_id UUID NOT NULL REFERENCES providers(id),
  submitted_by UUID NOT NULL REFERENCES provider_accounts(id),
  proposed_changes JSONB NOT NULL,
  evidence_refs JSONB NOT NULL DEFAULT '[]'::jsonb,
  status TEXT NOT NULL DEFAULT 'pending_review'
    CHECK (status IN ('pending_review','approved','rejected','needs_changes')),
  reviewer_note TEXT,
  reviewed_by TEXT,
  reviewed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE moderation_audit_log (
  id BIGSERIAL PRIMARY KEY,
  actor_subject TEXT NOT NULL,
  action TEXT NOT NULL,
  target_type TEXT NOT NULL,
  target_id UUID,
  reason TEXT,
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE user_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  provider_id UUID NOT NULL REFERENCES providers(id),
  report_type TEXT NOT NULL CHECK (report_type IN
    ('wrong_phone','wrong_address','closed','wrong_hours','duplicate','other')),
  description TEXT,
  reporter_contact TEXT,
  status TEXT NOT NULL DEFAULT 'open'
    CHECK (status IN ('open','in_review','resolved','dismissed')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Production requirements:
-- * Apply row-level security and least-privilege roles.
-- * Keep sensitive verification documents in private object storage,
--   not in public provider records.
-- * Add retention/deletion policies and immutable audit retention.
