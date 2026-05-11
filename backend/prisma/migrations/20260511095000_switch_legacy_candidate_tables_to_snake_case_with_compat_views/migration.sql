ALTER TABLE "Candidate" RENAME TO candidate;
ALTER TABLE candidate RENAME COLUMN "firstName" TO first_name;
ALTER TABLE candidate RENAME COLUMN "lastName" TO last_name;
ALTER TABLE candidate RENAME COLUMN "createdAt" TO created_at;
ALTER TABLE candidate RENAME COLUMN "updatedAt" TO updated_at;
ALTER TABLE candidate RENAME COLUMN "deletedAt" TO deleted_at;

ALTER TABLE "Education" RENAME TO education;
ALTER TABLE education RENAME COLUMN "startDate" TO start_date;
ALTER TABLE education RENAME COLUMN "endDate" TO end_date;
ALTER TABLE education RENAME COLUMN "candidateId" TO candidate_id;
ALTER TABLE education RENAME COLUMN "createdAt" TO created_at;
ALTER TABLE education RENAME COLUMN "updatedAt" TO updated_at;
ALTER TABLE education RENAME COLUMN "deletedAt" TO deleted_at;

ALTER TABLE "WorkExperience" RENAME TO work_experience;
ALTER TABLE work_experience RENAME COLUMN "startDate" TO start_date;
ALTER TABLE work_experience RENAME COLUMN "endDate" TO end_date;
ALTER TABLE work_experience RENAME COLUMN "candidateId" TO candidate_id;
ALTER TABLE work_experience RENAME COLUMN "createdAt" TO created_at;
ALTER TABLE work_experience RENAME COLUMN "updatedAt" TO updated_at;
ALTER TABLE work_experience RENAME COLUMN "deletedAt" TO deleted_at;

ALTER TABLE "Resume" RENAME TO resume;
ALTER TABLE resume RENAME COLUMN "filePath" TO file_path;
ALTER TABLE resume RENAME COLUMN "fileType" TO file_type;
ALTER TABLE resume RENAME COLUMN "uploadDate" TO upload_date;
ALTER TABLE resume RENAME COLUMN "candidateId" TO candidate_id;
ALTER TABLE resume RENAME COLUMN "createdAt" TO created_at;
ALTER TABLE resume RENAME COLUMN "updatedAt" TO updated_at;
ALTER TABLE resume RENAME COLUMN "deletedAt" TO deleted_at;

CREATE OR REPLACE VIEW "Candidate" AS
SELECT
  id,
  first_name AS "firstName",
  last_name AS "lastName",
  email,
  phone,
  address,
  created_at AS "createdAt",
  updated_at AS "updatedAt",
  deleted_at AS "deletedAt"
FROM candidate;

CREATE OR REPLACE FUNCTION legacy_candidate_view_write()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    IF NEW.id IS NULL THEN
      INSERT INTO candidate (first_name, last_name, email, phone, address, created_at, updated_at, deleted_at)
      VALUES (
        NEW."firstName",
        NEW."lastName",
        NEW.email,
        NEW.phone,
        NEW.address,
        COALESCE(NEW."createdAt", NOW()),
        COALESCE(NEW."updatedAt", NOW()),
        NEW."deletedAt"
      )
      RETURNING id, created_at, updated_at INTO NEW.id, NEW."createdAt", NEW."updatedAt";
    ELSE
      INSERT INTO candidate (id, first_name, last_name, email, phone, address, created_at, updated_at, deleted_at)
      VALUES (
        NEW.id,
        NEW."firstName",
        NEW."lastName",
        NEW.email,
        NEW.phone,
        NEW.address,
        COALESCE(NEW."createdAt", NOW()),
        COALESCE(NEW."updatedAt", NOW()),
        NEW."deletedAt"
      )
      RETURNING created_at, updated_at INTO NEW."createdAt", NEW."updatedAt";
    END IF;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE candidate
    SET
      first_name = NEW."firstName",
      last_name = NEW."lastName",
      email = NEW.email,
      phone = NEW.phone,
      address = NEW.address,
      updated_at = COALESCE(NEW."updatedAt", NOW()),
      deleted_at = NEW."deletedAt"
    WHERE id = OLD.id;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    DELETE FROM candidate WHERE id = OLD.id;
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$;

CREATE TRIGGER trg_legacy_candidate_view_write
INSTEAD OF INSERT OR UPDATE OR DELETE ON "Candidate"
FOR EACH ROW
EXECUTE FUNCTION legacy_candidate_view_write();

CREATE OR REPLACE VIEW "Education" AS
SELECT
  id,
  institution,
  title,
  start_date AS "startDate",
  end_date AS "endDate",
  candidate_id AS "candidateId",
  created_at AS "createdAt",
  updated_at AS "updatedAt",
  deleted_at AS "deletedAt"
FROM education;

CREATE OR REPLACE FUNCTION legacy_education_view_write()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    IF NEW.id IS NULL THEN
      INSERT INTO education (institution, title, start_date, end_date, candidate_id, created_at, updated_at, deleted_at)
      VALUES (
        NEW.institution,
        NEW.title,
        NEW."startDate",
        NEW."endDate",
        NEW."candidateId",
        COALESCE(NEW."createdAt", NOW()),
        COALESCE(NEW."updatedAt", NOW()),
        NEW."deletedAt"
      )
      RETURNING id, created_at, updated_at INTO NEW.id, NEW."createdAt", NEW."updatedAt";
    ELSE
      INSERT INTO education (id, institution, title, start_date, end_date, candidate_id, created_at, updated_at, deleted_at)
      VALUES (
        NEW.id,
        NEW.institution,
        NEW.title,
        NEW."startDate",
        NEW."endDate",
        NEW."candidateId",
        COALESCE(NEW."createdAt", NOW()),
        COALESCE(NEW."updatedAt", NOW()),
        NEW."deletedAt"
      )
      RETURNING created_at, updated_at INTO NEW."createdAt", NEW."updatedAt";
    END IF;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE education
    SET
      institution = NEW.institution,
      title = NEW.title,
      start_date = NEW."startDate",
      end_date = NEW."endDate",
      candidate_id = NEW."candidateId",
      updated_at = COALESCE(NEW."updatedAt", NOW()),
      deleted_at = NEW."deletedAt"
    WHERE id = OLD.id;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    DELETE FROM education WHERE id = OLD.id;
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$;

CREATE TRIGGER trg_legacy_education_view_write
INSTEAD OF INSERT OR UPDATE OR DELETE ON "Education"
FOR EACH ROW
EXECUTE FUNCTION legacy_education_view_write();

CREATE OR REPLACE VIEW "WorkExperience" AS
SELECT
  id,
  company,
  position,
  description,
  start_date AS "startDate",
  end_date AS "endDate",
  candidate_id AS "candidateId",
  created_at AS "createdAt",
  updated_at AS "updatedAt",
  deleted_at AS "deletedAt"
FROM work_experience;

CREATE OR REPLACE FUNCTION legacy_work_experience_view_write()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    IF NEW.id IS NULL THEN
      INSERT INTO work_experience (company, position, description, start_date, end_date, candidate_id, created_at, updated_at, deleted_at)
      VALUES (
        NEW.company,
        NEW.position,
        NEW.description,
        NEW."startDate",
        NEW."endDate",
        NEW."candidateId",
        COALESCE(NEW."createdAt", NOW()),
        COALESCE(NEW."updatedAt", NOW()),
        NEW."deletedAt"
      )
      RETURNING id, created_at, updated_at INTO NEW.id, NEW."createdAt", NEW."updatedAt";
    ELSE
      INSERT INTO work_experience (id, company, position, description, start_date, end_date, candidate_id, created_at, updated_at, deleted_at)
      VALUES (
        NEW.id,
        NEW.company,
        NEW.position,
        NEW.description,
        NEW."startDate",
        NEW."endDate",
        NEW."candidateId",
        COALESCE(NEW."createdAt", NOW()),
        COALESCE(NEW."updatedAt", NOW()),
        NEW."deletedAt"
      )
      RETURNING created_at, updated_at INTO NEW."createdAt", NEW."updatedAt";
    END IF;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE work_experience
    SET
      company = NEW.company,
      position = NEW.position,
      description = NEW.description,
      start_date = NEW."startDate",
      end_date = NEW."endDate",
      candidate_id = NEW."candidateId",
      updated_at = COALESCE(NEW."updatedAt", NOW()),
      deleted_at = NEW."deletedAt"
    WHERE id = OLD.id;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    DELETE FROM work_experience WHERE id = OLD.id;
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$;

CREATE TRIGGER trg_legacy_work_experience_view_write
INSTEAD OF INSERT OR UPDATE OR DELETE ON "WorkExperience"
FOR EACH ROW
EXECUTE FUNCTION legacy_work_experience_view_write();

CREATE OR REPLACE VIEW "Resume" AS
SELECT
  id,
  file_path AS "filePath",
  file_type AS "fileType",
  upload_date AS "uploadDate",
  candidate_id AS "candidateId",
  created_at AS "createdAt",
  updated_at AS "updatedAt",
  deleted_at AS "deletedAt"
FROM resume;

CREATE OR REPLACE FUNCTION legacy_resume_view_write()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    IF NEW.id IS NULL THEN
      INSERT INTO resume (file_path, file_type, upload_date, candidate_id, created_at, updated_at, deleted_at)
      VALUES (
        NEW."filePath",
        NEW."fileType",
        NEW."uploadDate",
        NEW."candidateId",
        COALESCE(NEW."createdAt", NOW()),
        COALESCE(NEW."updatedAt", NOW()),
        NEW."deletedAt"
      )
      RETURNING id, created_at, updated_at INTO NEW.id, NEW."createdAt", NEW."updatedAt";
    ELSE
      INSERT INTO resume (id, file_path, file_type, upload_date, candidate_id, created_at, updated_at, deleted_at)
      VALUES (
        NEW.id,
        NEW."filePath",
        NEW."fileType",
        NEW."uploadDate",
        NEW."candidateId",
        COALESCE(NEW."createdAt", NOW()),
        COALESCE(NEW."updatedAt", NOW()),
        NEW."deletedAt"
      )
      RETURNING created_at, updated_at INTO NEW."createdAt", NEW."updatedAt";
    END IF;
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    UPDATE resume
    SET
      file_path = NEW."filePath",
      file_type = NEW."fileType",
      upload_date = NEW."uploadDate",
      candidate_id = NEW."candidateId",
      updated_at = COALESCE(NEW."updatedAt", NOW()),
      deleted_at = NEW."deletedAt"
    WHERE id = OLD.id;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    DELETE FROM resume WHERE id = OLD.id;
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$;

CREATE TRIGGER trg_legacy_resume_view_write
INSTEAD OF INSERT OR UPDATE OR DELETE ON "Resume"
FOR EACH ROW
EXECUTE FUNCTION legacy_resume_view_write();
