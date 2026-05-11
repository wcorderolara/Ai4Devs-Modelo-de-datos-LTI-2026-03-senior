DROP TRIGGER IF EXISTS trg_legacy_candidate_view_write ON "Candidate";
DROP VIEW IF EXISTS "Candidate";
DROP FUNCTION IF EXISTS legacy_candidate_view_write();

DROP TRIGGER IF EXISTS trg_legacy_education_view_write ON "Education";
DROP VIEW IF EXISTS "Education";
DROP FUNCTION IF EXISTS legacy_education_view_write();

DROP TRIGGER IF EXISTS trg_legacy_work_experience_view_write ON "WorkExperience";
DROP VIEW IF EXISTS "WorkExperience";
DROP FUNCTION IF EXISTS legacy_work_experience_view_write();

DROP TRIGGER IF EXISTS trg_legacy_resume_view_write ON "Resume";
DROP VIEW IF EXISTS "Resume";
DROP FUNCTION IF EXISTS legacy_resume_view_write();

ALTER TABLE candidate
  ALTER COLUMN created_at SET NOT NULL,
  ALTER COLUMN updated_at SET NOT NULL,
  ALTER COLUMN created_at SET DEFAULT NOW(),
  ALTER COLUMN updated_at SET DEFAULT NOW();

ALTER TABLE education
  ALTER COLUMN candidate_id SET NOT NULL,
  ALTER COLUMN created_at SET NOT NULL,
  ALTER COLUMN updated_at SET NOT NULL,
  ALTER COLUMN created_at SET DEFAULT NOW(),
  ALTER COLUMN updated_at SET DEFAULT NOW();

ALTER TABLE work_experience
  ALTER COLUMN candidate_id SET NOT NULL,
  ALTER COLUMN created_at SET NOT NULL,
  ALTER COLUMN updated_at SET NOT NULL,
  ALTER COLUMN created_at SET DEFAULT NOW(),
  ALTER COLUMN updated_at SET DEFAULT NOW();

ALTER TABLE resume
  ALTER COLUMN candidate_id SET NOT NULL,
  ALTER COLUMN upload_date SET NOT NULL,
  ALTER COLUMN created_at SET NOT NULL,
  ALTER COLUMN updated_at SET NOT NULL,
  ALTER COLUMN created_at SET DEFAULT NOW(),
  ALTER COLUMN updated_at SET DEFAULT NOW();

ALTER TABLE education
  VALIDATE CONSTRAINT chk_education_date_range;

ALTER TABLE work_experience
  VALIDATE CONSTRAINT chk_work_experience_date_range;
