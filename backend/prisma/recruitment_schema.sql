CREATE TABLE company (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE employee (
    id SERIAL PRIMARY KEY,
    company_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    role VARCHAR(100) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_employee_company
        FOREIGN KEY (company_id)
        REFERENCES company (id)
        ON DELETE CASCADE
);

CREATE TABLE interview_flow (
    id SERIAL PRIMARY KEY,
    description TEXT
);

CREATE TABLE interview_type (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT
);

CREATE TABLE position (
    id SERIAL PRIMARY KEY,
    company_id INT NOT NULL,
    interview_flow_id INT NOT NULL UNIQUE,
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
    employment_type VARCHAR(100),
    benefits TEXT,
    company_description TEXT,
    application_deadline DATE,
    contact_info VARCHAR(255),
    CONSTRAINT fk_position_company
        FOREIGN KEY (company_id)
        REFERENCES company (id)
        ON DELETE CASCADE,
    CONSTRAINT fk_position_interview_flow
        FOREIGN KEY (interview_flow_id)
        REFERENCES interview_flow (id)
        ON DELETE RESTRICT,
    CONSTRAINT chk_position_salary
        CHECK (
            salary_min IS NULL
            OR salary_max IS NULL
            OR salary_min <= salary_max
        )
);

CREATE TABLE interview_step (
    id SERIAL PRIMARY KEY,
    interview_flow_id INT NOT NULL,
    interview_type_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    order_index INT NOT NULL,
    CONSTRAINT fk_interview_step_flow
        FOREIGN KEY (interview_flow_id)
        REFERENCES interview_flow (id)
        ON DELETE CASCADE,
    CONSTRAINT fk_interview_step_type
        FOREIGN KEY (interview_type_id)
        REFERENCES interview_type (id)
        ON DELETE RESTRICT,
    CONSTRAINT uq_interview_step_order
        UNIQUE (interview_flow_id, order_index)
);

CREATE TABLE candidate (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(30),
    address VARCHAR(255)
);

CREATE TABLE application (
    id SERIAL PRIMARY KEY,
    position_id INT NOT NULL,
    candidate_id INT NOT NULL,
    application_date DATE NOT NULL,
    status VARCHAR(50) NOT NULL,
    notes TEXT,
    CONSTRAINT fk_application_position
        FOREIGN KEY (position_id)
        REFERENCES position (id)
        ON DELETE CASCADE,
    CONSTRAINT fk_application_candidate
        FOREIGN KEY (candidate_id)
        REFERENCES candidate (id)
        ON DELETE CASCADE,
    CONSTRAINT uq_application_candidate_position
        UNIQUE (position_id, candidate_id)
);

CREATE TABLE interview (
    id SERIAL PRIMARY KEY,
    application_id INT NOT NULL,
    interview_step_id INT NOT NULL,
    employee_id INT NOT NULL,
    interview_date DATE NOT NULL,
    result VARCHAR(50),
    score INT,
    notes TEXT,
    CONSTRAINT fk_interview_application
        FOREIGN KEY (application_id)
        REFERENCES application (id)
        ON DELETE CASCADE,
    CONSTRAINT fk_interview_step
        FOREIGN KEY (interview_step_id)
        REFERENCES interview_step (id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_interview_employee
        FOREIGN KEY (employee_id)
        REFERENCES employee (id)
        ON DELETE RESTRICT,
    CONSTRAINT uq_interview_application_step
        UNIQUE (application_id, interview_step_id),
    CONSTRAINT chk_interview_score
        CHECK (score IS NULL OR score BETWEEN 0 AND 100)
);

CREATE INDEX idx_employee_company_id ON employee (company_id);
CREATE INDEX idx_position_company_id ON position (company_id);
CREATE INDEX idx_position_interview_flow_id ON position (interview_flow_id);
CREATE INDEX idx_interview_step_flow_id ON interview_step (interview_flow_id);
CREATE INDEX idx_interview_step_type_id ON interview_step (interview_type_id);
CREATE INDEX idx_application_position_id ON application (position_id);
CREATE INDEX idx_application_candidate_id ON application (candidate_id);
CREATE INDEX idx_interview_application_id ON interview (application_id);
CREATE INDEX idx_interview_step_id ON interview (interview_step_id);
CREATE INDEX idx_interview_employee_id ON interview (employee_id);
