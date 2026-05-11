CREATE TABLE company (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  created_at TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
  deleted_at TIMESTAMPTZ(3)
);

CREATE TABLE employee (
  id SERIAL PRIMARY KEY,
  company_id INT NOT NULL,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL,
  role VARCHAR(100) NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
  deleted_at TIMESTAMPTZ(3),
  CONSTRAINT fk_employee_company
    FOREIGN KEY (company_id)
    REFERENCES company (id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);

CREATE TABLE interview_flow (
  id SERIAL PRIMARY KEY,
  company_id INT NOT NULL,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  created_by_employee_id INT,
  created_at TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
  deleted_at TIMESTAMPTZ(3),
  CONSTRAINT fk_interview_flow_company
    FOREIGN KEY (company_id)
    REFERENCES company (id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT fk_interview_flow_created_by_employee
    FOREIGN KEY (created_by_employee_id)
    REFERENCES employee (id)
    ON DELETE SET NULL
    ON UPDATE CASCADE
);

CREATE TABLE interview_flow_version (
  id SERIAL PRIMARY KEY,
  company_id INT NOT NULL,
  interview_flow_id INT NOT NULL,
  version_number INT NOT NULL,
  status VARCHAR(50) NOT NULL,
  change_summary TEXT,
  published_at TIMESTAMPTZ(3),
  created_by_employee_id INT,
  created_at TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
  deleted_at TIMESTAMPTZ(3),
  CONSTRAINT fk_interview_flow_version_company
    FOREIGN KEY (company_id)
    REFERENCES company (id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT fk_interview_flow_version_flow
    FOREIGN KEY (interview_flow_id)
    REFERENCES interview_flow (id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT fk_interview_flow_version_created_by_employee
    FOREIGN KEY (created_by_employee_id)
    REFERENCES employee (id)
    ON DELETE SET NULL
    ON UPDATE CASCADE,
  CONSTRAINT uq_interview_flow_version_number
    UNIQUE (interview_flow_id, version_number)
);

CREATE TABLE interview_type (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
  deleted_at TIMESTAMPTZ(3),
  CONSTRAINT uq_interview_type_name
    UNIQUE (name)
);

CREATE TABLE interview_step (
  id SERIAL PRIMARY KEY,
  company_id INT NOT NULL,
  interview_flow_version_id INT NOT NULL,
  interview_type_id INT NOT NULL,
  name VARCHAR(255) NOT NULL,
  order_index INT NOT NULL,
  instructions TEXT,
  estimated_duration_minutes INT,
  allow_reinterview BOOLEAN NOT NULL DEFAULT FALSE,
  panel_min_interviewers INT NOT NULL DEFAULT 1,
  panel_max_interviewers INT,
  created_at TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
  deleted_at TIMESTAMPTZ(3),
  CONSTRAINT fk_interview_step_company
    FOREIGN KEY (company_id)
    REFERENCES company (id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT fk_interview_step_flow_version
    FOREIGN KEY (interview_flow_version_id)
    REFERENCES interview_flow_version (id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT fk_interview_step_type
    FOREIGN KEY (interview_type_id)
    REFERENCES interview_type (id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT uq_interview_step_flow_version_order
    UNIQUE (interview_flow_version_id, order_index)
);

CREATE TABLE position (
  id SERIAL PRIMARY KEY,
  company_id INT NOT NULL,
  interview_flow_id INT NOT NULL,
  active_interview_flow_version_id INT NOT NULL,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  status VARCHAR(50) NOT NULL,
  is_visible BOOLEAN NOT NULL DEFAULT TRUE,
  location VARCHAR(255),
  job_description TEXT,
  requirements TEXT,
  responsibilities TEXT,
  salary_min NUMERIC(12, 2),
  salary_max NUMERIC(12, 2),
  employment_type VARCHAR(50),
  benefits TEXT,
  company_description TEXT,
  application_deadline DATE,
  contact_info VARCHAR(255),
  created_at TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
  deleted_at TIMESTAMPTZ(3),
  CONSTRAINT fk_position_company
    FOREIGN KEY (company_id)
    REFERENCES company (id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT fk_position_interview_flow
    FOREIGN KEY (interview_flow_id)
    REFERENCES interview_flow (id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT fk_position_active_interview_flow_version
    FOREIGN KEY (active_interview_flow_version_id)
    REFERENCES interview_flow_version (id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);

CREATE TABLE application (
  id SERIAL PRIMARY KEY,
  company_id INT NOT NULL,
  position_id INT NOT NULL,
  candidate_id INT NOT NULL,
  interview_flow_version_id INT NOT NULL,
  application_date DATE NOT NULL,
  status VARCHAR(50) NOT NULL,
  notes TEXT,
  closed_at TIMESTAMPTZ(3),
  created_at TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
  deleted_at TIMESTAMPTZ(3),
  CONSTRAINT fk_application_company
    FOREIGN KEY (company_id)
    REFERENCES company (id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT fk_application_position
    FOREIGN KEY (position_id)
    REFERENCES position (id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT fk_application_candidate
    FOREIGN KEY (candidate_id)
    REFERENCES "Candidate" (id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT fk_application_interview_flow_version
    FOREIGN KEY (interview_flow_version_id)
    REFERENCES interview_flow_version (id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);

CREATE TABLE application_status_history (
  id SERIAL PRIMARY KEY,
  company_id INT NOT NULL,
  application_id INT NOT NULL,
  from_status VARCHAR(50),
  to_status VARCHAR(50) NOT NULL,
  changed_by_employee_id INT,
  reason TEXT,
  metadata JSONB,
  changed_at TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
  CONSTRAINT fk_application_status_history_company
    FOREIGN KEY (company_id)
    REFERENCES company (id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT fk_application_status_history_application
    FOREIGN KEY (application_id)
    REFERENCES application (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT fk_application_status_history_changed_by_employee
    FOREIGN KEY (changed_by_employee_id)
    REFERENCES employee (id)
    ON DELETE SET NULL
    ON UPDATE CASCADE
);

CREATE TABLE interview (
  id SERIAL PRIMARY KEY,
  company_id INT NOT NULL,
  application_id INT NOT NULL,
  interview_step_id INT NOT NULL,
  attempt_number INT NOT NULL DEFAULT 1,
  status VARCHAR(50) NOT NULL,
  scheduled_start_at TIMESTAMPTZ(3) NOT NULL,
  scheduled_end_at TIMESTAMPTZ(3),
  completed_at TIMESTAMPTZ(3),
  scheduled_by_employee_id INT,
  lead_interviewer_id INT,
  result VARCHAR(50),
  score INT,
  notes TEXT,
  cancellation_reason TEXT,
  created_at TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
  deleted_at TIMESTAMPTZ(3),
  CONSTRAINT fk_interview_company
    FOREIGN KEY (company_id)
    REFERENCES company (id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT fk_interview_application
    FOREIGN KEY (application_id)
    REFERENCES application (id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT fk_interview_step
    FOREIGN KEY (interview_step_id)
    REFERENCES interview_step (id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT fk_interview_scheduled_by_employee
    FOREIGN KEY (scheduled_by_employee_id)
    REFERENCES employee (id)
    ON DELETE SET NULL
    ON UPDATE CASCADE,
  CONSTRAINT fk_interview_lead_interviewer
    FOREIGN KEY (lead_interviewer_id)
    REFERENCES employee (id)
    ON DELETE SET NULL
    ON UPDATE CASCADE,
  CONSTRAINT uq_interview_application_step_attempt
    UNIQUE (application_id, interview_step_id, attempt_number)
);

CREATE TABLE interview_interviewer (
  id SERIAL PRIMARY KEY,
  company_id INT NOT NULL,
  interview_id INT NOT NULL,
  employee_id INT NOT NULL,
  role VARCHAR(50) NOT NULL DEFAULT 'PANELIST',
  is_primary BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
  deleted_at TIMESTAMPTZ(3),
  CONSTRAINT fk_interview_interviewer_company
    FOREIGN KEY (company_id)
    REFERENCES company (id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT fk_interview_interviewer_interview
    FOREIGN KEY (interview_id)
    REFERENCES interview (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT fk_interview_interviewer_employee
    FOREIGN KEY (employee_id)
    REFERENCES employee (id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT uq_interview_interviewer_interview_employee
    UNIQUE (interview_id, employee_id)
);

CREATE TABLE interview_status_history (
  id SERIAL PRIMARY KEY,
  company_id INT NOT NULL,
  interview_id INT NOT NULL,
  from_status VARCHAR(50),
  to_status VARCHAR(50) NOT NULL,
  changed_by_employee_id INT,
  reason TEXT,
  metadata JSONB,
  changed_at TIMESTAMPTZ(3) NOT NULL DEFAULT NOW(),
  CONSTRAINT fk_interview_status_history_company
    FOREIGN KEY (company_id)
    REFERENCES company (id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT fk_interview_status_history_interview
    FOREIGN KEY (interview_id)
    REFERENCES interview (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT fk_interview_status_history_changed_by_employee
    FOREIGN KEY (changed_by_employee_id)
    REFERENCES employee (id)
    ON DELETE SET NULL
    ON UPDATE CASCADE
);
