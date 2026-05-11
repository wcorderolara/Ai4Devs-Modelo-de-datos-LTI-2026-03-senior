CREATE UNIQUE INDEX uq_employee_company_email
  ON employee (company_id, email);

CREATE INDEX idx_employee_company_active_deleted
  ON employee (company_id, is_active, deleted_at);

CREATE INDEX idx_interview_flow_company_deleted
  ON interview_flow (company_id, deleted_at);

CREATE INDEX idx_interview_flow_created_by_employee_id
  ON interview_flow (created_by_employee_id);

CREATE INDEX idx_interview_flow_version_company_status_deleted
  ON interview_flow_version (company_id, status, deleted_at);

CREATE INDEX idx_interview_flow_version_published_at
  ON interview_flow_version (published_at);

CREATE INDEX idx_interview_type_deleted_at
  ON interview_type (deleted_at);

CREATE INDEX idx_interview_step_flow_version_id
  ON interview_step (interview_flow_version_id);

CREATE INDEX idx_interview_step_company_type_deleted
  ON interview_step (company_id, interview_type_id, deleted_at);

CREATE INDEX idx_position_company_status_visible_deleted
  ON position (company_id, status, is_visible, deleted_at);

CREATE INDEX idx_position_company_application_deadline
  ON position (company_id, application_deadline);

CREATE INDEX idx_position_interview_flow_id
  ON position (interview_flow_id);

CREATE INDEX idx_position_active_flow_version_id
  ON position (active_interview_flow_version_id);

CREATE INDEX idx_application_company_position_status_deleted
  ON application (company_id, position_id, status, deleted_at);

CREATE INDEX idx_application_company_candidate_created_at
  ON application (company_id, candidate_id, created_at);

CREATE INDEX idx_application_position_application_date
  ON application (position_id, application_date);

CREATE INDEX idx_application_interview_flow_version_id
  ON application (interview_flow_version_id);

CREATE INDEX idx_application_closed_at
  ON application (closed_at);

CREATE UNIQUE INDEX uq_application_active_candidate_position
  ON application (company_id, position_id, candidate_id)
  WHERE deleted_at IS NULL AND closed_at IS NULL;

CREATE INDEX idx_application_status_history_application_changed_at
  ON application_status_history (application_id, changed_at);

CREATE INDEX idx_application_status_history_company_status_changed_at
  ON application_status_history (company_id, to_status, changed_at);

CREATE INDEX idx_interview_company_status_start_deleted
  ON interview (company_id, status, scheduled_start_at, deleted_at);

CREATE INDEX idx_interview_company_lead_status
  ON interview (company_id, lead_interviewer_id, status);

CREATE INDEX idx_interview_company_scheduler_status
  ON interview (company_id, scheduled_by_employee_id, status);

CREATE INDEX idx_interview_application_id
  ON interview (application_id);

CREATE INDEX idx_interview_interviewer_company_employee_deleted
  ON interview_interviewer (company_id, employee_id, deleted_at);

CREATE INDEX idx_interview_interviewer_interview_id
  ON interview_interviewer (interview_id);

CREATE INDEX idx_interview_status_history_interview_changed_at
  ON interview_status_history (interview_id, changed_at);

CREATE INDEX idx_interview_status_history_company_status_changed_at
  ON interview_status_history (company_id, to_status, changed_at);

CREATE INDEX idx_candidate_deleted_at
  ON "Candidate" ("deletedAt");

CREATE INDEX idx_education_candidate_deleted
  ON "Education" ("candidateId", "deletedAt");

CREATE INDEX idx_work_experience_candidate_deleted
  ON "WorkExperience" ("candidateId", "deletedAt");

CREATE INDEX idx_resume_candidate_deleted
  ON "Resume" ("candidateId", "deletedAt");

CREATE INDEX idx_resume_candidate_uploaded_at
  ON "Resume" ("candidateId", "uploadDate");

ALTER TABLE "Education"
  ADD CONSTRAINT chk_education_date_range
  CHECK ("endDate" IS NULL OR "endDate" >= "startDate")
  NOT VALID;

ALTER TABLE "WorkExperience"
  ADD CONSTRAINT chk_work_experience_date_range
  CHECK ("endDate" IS NULL OR "endDate" >= "startDate")
  NOT VALID;

ALTER TABLE interview_step
  ADD CONSTRAINT chk_interview_step_panel_bounds
  CHECK (
    panel_min_interviewers >= 1
    AND (
      panel_max_interviewers IS NULL
      OR panel_max_interviewers >= panel_min_interviewers
    )
  );

ALTER TABLE position
  ADD CONSTRAINT chk_position_salary
  CHECK (
    salary_min IS NULL
    OR salary_max IS NULL
    OR salary_min <= salary_max
  ),
  ADD CONSTRAINT chk_position_application_deadline
  CHECK (
    application_deadline IS NULL
    OR application_deadline >= DATE(created_at)
  );

ALTER TABLE application
  ADD CONSTRAINT chk_application_closed_at
  CHECK (closed_at IS NULL OR closed_at >= created_at);

ALTER TABLE interview
  ADD CONSTRAINT chk_interview_score
  CHECK (score IS NULL OR score BETWEEN 0 AND 100),
  ADD CONSTRAINT chk_interview_attempt_number
  CHECK (attempt_number >= 1),
  ADD CONSTRAINT chk_interview_schedule
  CHECK (
    (scheduled_end_at IS NULL OR scheduled_end_at >= scheduled_start_at)
    AND (completed_at IS NULL OR completed_at >= scheduled_start_at)
  );

DROP TRIGGER IF EXISTS trg_company_updated_at ON company;
CREATE TRIGGER trg_company_updated_at
BEFORE UPDATE ON company
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_employee_updated_at ON employee;
CREATE TRIGGER trg_employee_updated_at
BEFORE UPDATE ON employee
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_interview_flow_updated_at ON interview_flow;
CREATE TRIGGER trg_interview_flow_updated_at
BEFORE UPDATE ON interview_flow
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_interview_flow_version_updated_at ON interview_flow_version;
CREATE TRIGGER trg_interview_flow_version_updated_at
BEFORE UPDATE ON interview_flow_version
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_interview_type_updated_at ON interview_type;
CREATE TRIGGER trg_interview_type_updated_at
BEFORE UPDATE ON interview_type
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_interview_step_updated_at ON interview_step;
CREATE TRIGGER trg_interview_step_updated_at
BEFORE UPDATE ON interview_step
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_position_updated_at ON position;
CREATE TRIGGER trg_position_updated_at
BEFORE UPDATE ON position
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_application_updated_at ON application;
CREATE TRIGGER trg_application_updated_at
BEFORE UPDATE ON application
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_interview_updated_at ON interview;
CREATE TRIGGER trg_interview_updated_at
BEFORE UPDATE ON interview
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_interview_interviewer_updated_at ON interview_interviewer;
CREATE TRIGGER trg_interview_interviewer_updated_at
BEFORE UPDATE ON interview_interviewer
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();
