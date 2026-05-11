DO $$
BEGIN
  CREATE TYPE employee_role AS ENUM ('ADMIN', 'RECRUITER', 'HIRING_MANAGER', 'INTERVIEWER', 'COORDINATOR');
EXCEPTION
  WHEN duplicate_object THEN NULL;
END
$$;

DO $$
BEGIN
  CREATE TYPE interviewer_role AS ENUM ('LEAD', 'PANELIST', 'OBSERVER');
EXCEPTION
  WHEN duplicate_object THEN NULL;
END
$$;

DO $$
BEGIN
  CREATE TYPE interview_flow_version_status AS ENUM ('DRAFT', 'PUBLISHED', 'ARCHIVED');
EXCEPTION
  WHEN duplicate_object THEN NULL;
END
$$;

DO $$
BEGIN
  CREATE TYPE position_status AS ENUM ('DRAFT', 'OPEN', 'PAUSED', 'CLOSED', 'FILLED', 'ARCHIVED');
EXCEPTION
  WHEN duplicate_object THEN NULL;
END
$$;

DO $$
BEGIN
  CREATE TYPE employment_type AS ENUM ('FULL_TIME', 'PART_TIME', 'CONTRACT', 'TEMPORARY', 'INTERN', 'FREELANCE');
EXCEPTION
  WHEN duplicate_object THEN NULL;
END
$$;

DO $$
BEGIN
  CREATE TYPE application_status AS ENUM (
    'SUBMITTED',
    'IN_REVIEW',
    'INTERVIEW_SCHEDULED',
    'INTERVIEW_IN_PROGRESS',
    'OFFER_EXTENDED',
    'HIRED',
    'REJECTED',
    'WITHDRAWN'
  );
EXCEPTION
  WHEN duplicate_object THEN NULL;
END
$$;

DO $$
BEGIN
  CREATE TYPE interview_status AS ENUM (
    'SCHEDULED',
    'RESCHEDULED',
    'IN_PROGRESS',
    'COMPLETED',
    'CANCELLED',
    'NO_SHOW',
    'FEEDBACK_PENDING'
  );
EXCEPTION
  WHEN duplicate_object THEN NULL;
END
$$;

DO $$
BEGIN
  CREATE TYPE interview_result AS ENUM (
    'STRONG_HIRE',
    'HIRE',
    'MAYBE',
    'NO_HIRE',
    'CANCELLED',
    'NO_SHOW'
  );
EXCEPTION
  WHEN duplicate_object THEN NULL;
END
$$;

ALTER TABLE interview_interviewer
  ALTER COLUMN role DROP DEFAULT,
  ALTER COLUMN role TYPE interviewer_role
    USING CASE
      WHEN role = 'LEAD' THEN 'LEAD'::interviewer_role
      WHEN role = 'PANELIST' THEN 'PANELIST'::interviewer_role
      WHEN role = 'OBSERVER' THEN 'OBSERVER'::interviewer_role
      ELSE NULL
    END,
  ALTER COLUMN role SET DEFAULT 'PANELIST'::interviewer_role;

ALTER TABLE employee
  ALTER COLUMN role TYPE employee_role
    USING CASE
      WHEN role = 'ADMIN' THEN 'ADMIN'::employee_role
      WHEN role = 'RECRUITER' THEN 'RECRUITER'::employee_role
      WHEN role = 'HIRING_MANAGER' THEN 'HIRING_MANAGER'::employee_role
      WHEN role = 'INTERVIEWER' THEN 'INTERVIEWER'::employee_role
      WHEN role = 'COORDINATOR' THEN 'COORDINATOR'::employee_role
      ELSE NULL
    END;

ALTER TABLE interview_flow_version
  ALTER COLUMN status TYPE interview_flow_version_status
    USING CASE
      WHEN status = 'DRAFT' THEN 'DRAFT'::interview_flow_version_status
      WHEN status = 'PUBLISHED' THEN 'PUBLISHED'::interview_flow_version_status
      WHEN status = 'ARCHIVED' THEN 'ARCHIVED'::interview_flow_version_status
      ELSE NULL
    END;

ALTER TABLE position
  ALTER COLUMN status TYPE position_status
    USING CASE
      WHEN status = 'DRAFT' THEN 'DRAFT'::position_status
      WHEN status = 'OPEN' THEN 'OPEN'::position_status
      WHEN status = 'PAUSED' THEN 'PAUSED'::position_status
      WHEN status = 'CLOSED' THEN 'CLOSED'::position_status
      WHEN status = 'FILLED' THEN 'FILLED'::position_status
      WHEN status = 'ARCHIVED' THEN 'ARCHIVED'::position_status
      ELSE NULL
    END,
  ALTER COLUMN employment_type TYPE employment_type
    USING CASE
      WHEN employment_type IS NULL THEN NULL
      WHEN employment_type = 'FULL_TIME' THEN 'FULL_TIME'::employment_type
      WHEN employment_type = 'PART_TIME' THEN 'PART_TIME'::employment_type
      WHEN employment_type = 'CONTRACT' THEN 'CONTRACT'::employment_type
      WHEN employment_type = 'TEMPORARY' THEN 'TEMPORARY'::employment_type
      WHEN employment_type = 'INTERN' THEN 'INTERN'::employment_type
      WHEN employment_type = 'FREELANCE' THEN 'FREELANCE'::employment_type
      ELSE NULL
    END;

ALTER TABLE application
  ALTER COLUMN status TYPE application_status
    USING CASE
      WHEN status = 'SUBMITTED' THEN 'SUBMITTED'::application_status
      WHEN status = 'IN_REVIEW' THEN 'IN_REVIEW'::application_status
      WHEN status = 'INTERVIEW_SCHEDULED' THEN 'INTERVIEW_SCHEDULED'::application_status
      WHEN status = 'INTERVIEW_IN_PROGRESS' THEN 'INTERVIEW_IN_PROGRESS'::application_status
      WHEN status = 'OFFER_EXTENDED' THEN 'OFFER_EXTENDED'::application_status
      WHEN status = 'HIRED' THEN 'HIRED'::application_status
      WHEN status = 'REJECTED' THEN 'REJECTED'::application_status
      WHEN status = 'WITHDRAWN' THEN 'WITHDRAWN'::application_status
      ELSE NULL
    END;

ALTER TABLE application_status_history
  ALTER COLUMN from_status TYPE application_status
    USING CASE
      WHEN from_status IS NULL THEN NULL
      WHEN from_status = 'SUBMITTED' THEN 'SUBMITTED'::application_status
      WHEN from_status = 'IN_REVIEW' THEN 'IN_REVIEW'::application_status
      WHEN from_status = 'INTERVIEW_SCHEDULED' THEN 'INTERVIEW_SCHEDULED'::application_status
      WHEN from_status = 'INTERVIEW_IN_PROGRESS' THEN 'INTERVIEW_IN_PROGRESS'::application_status
      WHEN from_status = 'OFFER_EXTENDED' THEN 'OFFER_EXTENDED'::application_status
      WHEN from_status = 'HIRED' THEN 'HIRED'::application_status
      WHEN from_status = 'REJECTED' THEN 'REJECTED'::application_status
      WHEN from_status = 'WITHDRAWN' THEN 'WITHDRAWN'::application_status
      ELSE NULL
    END,
  ALTER COLUMN to_status TYPE application_status
    USING CASE
      WHEN to_status = 'SUBMITTED' THEN 'SUBMITTED'::application_status
      WHEN to_status = 'IN_REVIEW' THEN 'IN_REVIEW'::application_status
      WHEN to_status = 'INTERVIEW_SCHEDULED' THEN 'INTERVIEW_SCHEDULED'::application_status
      WHEN to_status = 'INTERVIEW_IN_PROGRESS' THEN 'INTERVIEW_IN_PROGRESS'::application_status
      WHEN to_status = 'OFFER_EXTENDED' THEN 'OFFER_EXTENDED'::application_status
      WHEN to_status = 'HIRED' THEN 'HIRED'::application_status
      WHEN to_status = 'REJECTED' THEN 'REJECTED'::application_status
      WHEN to_status = 'WITHDRAWN' THEN 'WITHDRAWN'::application_status
      ELSE NULL
    END;

ALTER TABLE interview
  ALTER COLUMN status TYPE interview_status
    USING CASE
      WHEN status = 'SCHEDULED' THEN 'SCHEDULED'::interview_status
      WHEN status = 'RESCHEDULED' THEN 'RESCHEDULED'::interview_status
      WHEN status = 'IN_PROGRESS' THEN 'IN_PROGRESS'::interview_status
      WHEN status = 'COMPLETED' THEN 'COMPLETED'::interview_status
      WHEN status = 'CANCELLED' THEN 'CANCELLED'::interview_status
      WHEN status = 'NO_SHOW' THEN 'NO_SHOW'::interview_status
      WHEN status = 'FEEDBACK_PENDING' THEN 'FEEDBACK_PENDING'::interview_status
      ELSE NULL
    END,
  ALTER COLUMN result TYPE interview_result
    USING CASE
      WHEN result IS NULL THEN NULL
      WHEN result = 'STRONG_HIRE' THEN 'STRONG_HIRE'::interview_result
      WHEN result = 'HIRE' THEN 'HIRE'::interview_result
      WHEN result = 'MAYBE' THEN 'MAYBE'::interview_result
      WHEN result = 'NO_HIRE' THEN 'NO_HIRE'::interview_result
      WHEN result = 'CANCELLED' THEN 'CANCELLED'::interview_result
      WHEN result = 'NO_SHOW' THEN 'NO_SHOW'::interview_result
      ELSE NULL
    END;

ALTER TABLE interview_status_history
  ALTER COLUMN from_status TYPE interview_status
    USING CASE
      WHEN from_status IS NULL THEN NULL
      WHEN from_status = 'SCHEDULED' THEN 'SCHEDULED'::interview_status
      WHEN from_status = 'RESCHEDULED' THEN 'RESCHEDULED'::interview_status
      WHEN from_status = 'IN_PROGRESS' THEN 'IN_PROGRESS'::interview_status
      WHEN from_status = 'COMPLETED' THEN 'COMPLETED'::interview_status
      WHEN from_status = 'CANCELLED' THEN 'CANCELLED'::interview_status
      WHEN from_status = 'NO_SHOW' THEN 'NO_SHOW'::interview_status
      WHEN from_status = 'FEEDBACK_PENDING' THEN 'FEEDBACK_PENDING'::interview_status
      ELSE NULL
    END,
  ALTER COLUMN to_status TYPE interview_status
    USING CASE
      WHEN to_status = 'SCHEDULED' THEN 'SCHEDULED'::interview_status
      WHEN to_status = 'RESCHEDULED' THEN 'RESCHEDULED'::interview_status
      WHEN to_status = 'IN_PROGRESS' THEN 'IN_PROGRESS'::interview_status
      WHEN to_status = 'COMPLETED' THEN 'COMPLETED'::interview_status
      WHEN to_status = 'CANCELLED' THEN 'CANCELLED'::interview_status
      WHEN to_status = 'NO_SHOW' THEN 'NO_SHOW'::interview_status
      WHEN to_status = 'FEEDBACK_PENDING' THEN 'FEEDBACK_PENDING'::interview_status
      ELSE NULL
    END;
