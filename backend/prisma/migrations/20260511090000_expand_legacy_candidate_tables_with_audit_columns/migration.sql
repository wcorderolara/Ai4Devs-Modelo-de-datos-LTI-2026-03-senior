CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

ALTER TABLE "Candidate"
  ADD COLUMN IF NOT EXISTS "createdAt" TIMESTAMPTZ(3),
  ADD COLUMN IF NOT EXISTS "updatedAt" TIMESTAMPTZ(3),
  ADD COLUMN IF NOT EXISTS "deletedAt" TIMESTAMPTZ(3);

ALTER TABLE "Candidate"
  ALTER COLUMN "createdAt" SET DEFAULT NOW(),
  ALTER COLUMN "updatedAt" SET DEFAULT NOW();

DROP TRIGGER IF EXISTS trg_candidate_legacy_updated_at ON "Candidate";
CREATE TRIGGER trg_candidate_legacy_updated_at
BEFORE UPDATE ON "Candidate"
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

ALTER TABLE "Education"
  ADD COLUMN IF NOT EXISTS "createdAt" TIMESTAMPTZ(3),
  ADD COLUMN IF NOT EXISTS "updatedAt" TIMESTAMPTZ(3),
  ADD COLUMN IF NOT EXISTS "deletedAt" TIMESTAMPTZ(3);

ALTER TABLE "Education"
  ALTER COLUMN "createdAt" SET DEFAULT NOW(),
  ALTER COLUMN "updatedAt" SET DEFAULT NOW();

DROP TRIGGER IF EXISTS trg_education_legacy_updated_at ON "Education";
CREATE TRIGGER trg_education_legacy_updated_at
BEFORE UPDATE ON "Education"
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

ALTER TABLE "WorkExperience"
  ADD COLUMN IF NOT EXISTS "createdAt" TIMESTAMPTZ(3),
  ADD COLUMN IF NOT EXISTS "updatedAt" TIMESTAMPTZ(3),
  ADD COLUMN IF NOT EXISTS "deletedAt" TIMESTAMPTZ(3);

ALTER TABLE "WorkExperience"
  ALTER COLUMN "createdAt" SET DEFAULT NOW(),
  ALTER COLUMN "updatedAt" SET DEFAULT NOW();

DROP TRIGGER IF EXISTS trg_work_experience_legacy_updated_at ON "WorkExperience";
CREATE TRIGGER trg_work_experience_legacy_updated_at
BEFORE UPDATE ON "WorkExperience"
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

ALTER TABLE "Resume"
  ADD COLUMN IF NOT EXISTS "createdAt" TIMESTAMPTZ(3),
  ADD COLUMN IF NOT EXISTS "updatedAt" TIMESTAMPTZ(3),
  ADD COLUMN IF NOT EXISTS "deletedAt" TIMESTAMPTZ(3);

ALTER TABLE "Resume"
  ALTER COLUMN "createdAt" SET DEFAULT NOW(),
  ALTER COLUMN "updatedAt" SET DEFAULT NOW();

DROP TRIGGER IF EXISTS trg_resume_legacy_updated_at ON "Resume";
CREATE TRIGGER trg_resume_legacy_updated_at
BEFORE UPDATE ON "Resume"
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();
