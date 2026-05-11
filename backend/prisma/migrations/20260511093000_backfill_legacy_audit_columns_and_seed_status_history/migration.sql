UPDATE "Candidate"
SET
  "createdAt" = COALESCE("createdAt", NOW()),
  "updatedAt" = COALESCE("updatedAt", NOW())
WHERE "createdAt" IS NULL OR "updatedAt" IS NULL;

UPDATE "Education"
SET
  "createdAt" = COALESCE("createdAt", NOW()),
  "updatedAt" = COALESCE("updatedAt", NOW())
WHERE "createdAt" IS NULL OR "updatedAt" IS NULL;

UPDATE "WorkExperience"
SET
  "createdAt" = COALESCE("createdAt", NOW()),
  "updatedAt" = COALESCE("updatedAt", NOW())
WHERE "createdAt" IS NULL OR "updatedAt" IS NULL;

UPDATE "Resume"
SET
  "createdAt" = COALESCE("createdAt", "uploadDate"::timestamptz, NOW()),
  "updatedAt" = COALESCE("updatedAt", "uploadDate"::timestamptz, NOW())
WHERE "createdAt" IS NULL OR "updatedAt" IS NULL;

UPDATE employee
SET role = UPPER(REPLACE(TRIM(role), ' ', '_'))
WHERE role <> UPPER(REPLACE(TRIM(role), ' ', '_'));

UPDATE interview_flow_version
SET status = UPPER(REPLACE(TRIM(status), ' ', '_'))
WHERE status <> UPPER(REPLACE(TRIM(status), ' ', '_'));

UPDATE position
SET
  status = UPPER(REPLACE(TRIM(status), ' ', '_')),
  employment_type = CASE
    WHEN employment_type IS NULL THEN NULL
    ELSE UPPER(REPLACE(TRIM(employment_type), ' ', '_'))
  END
WHERE
  status <> UPPER(REPLACE(TRIM(status), ' ', '_'))
  OR (
    employment_type IS NOT NULL
    AND employment_type <> UPPER(REPLACE(TRIM(employment_type), ' ', '_'))
  );

UPDATE application
SET
  status = UPPER(REPLACE(TRIM(status), ' ', '_')),
  closed_at = CASE
    WHEN closed_at IS NOT NULL THEN closed_at
    WHEN UPPER(REPLACE(TRIM(status), ' ', '_')) IN ('HIRED', 'REJECTED', 'WITHDRAWN') THEN COALESCE(updated_at, created_at, NOW())
    ELSE NULL
  END
WHERE
  status <> UPPER(REPLACE(TRIM(status), ' ', '_'))
  OR (
    closed_at IS NULL
    AND UPPER(REPLACE(TRIM(status), ' ', '_')) IN ('HIRED', 'REJECTED', 'WITHDRAWN')
  );

UPDATE application_status_history
SET
  from_status = CASE
    WHEN from_status IS NULL THEN NULL
    ELSE UPPER(REPLACE(TRIM(from_status), ' ', '_'))
  END,
  to_status = UPPER(REPLACE(TRIM(to_status), ' ', '_'));

UPDATE interview
SET
  status = UPPER(REPLACE(TRIM(status), ' ', '_')),
  result = CASE
    WHEN result IS NULL THEN NULL
    ELSE UPPER(REPLACE(TRIM(result), ' ', '_'))
  END
WHERE
  status <> UPPER(REPLACE(TRIM(status), ' ', '_'))
  OR (
    result IS NOT NULL
    AND result <> UPPER(REPLACE(TRIM(result), ' ', '_'))
  );

UPDATE interview_interviewer
SET role = UPPER(REPLACE(TRIM(role), ' ', '_'))
WHERE role <> UPPER(REPLACE(TRIM(role), ' ', '_'));

UPDATE interview_status_history
SET
  from_status = CASE
    WHEN from_status IS NULL THEN NULL
    ELSE UPPER(REPLACE(TRIM(from_status), ' ', '_'))
  END,
  to_status = UPPER(REPLACE(TRIM(to_status), ' ', '_'));

INSERT INTO application_status_history (
  company_id,
  application_id,
  from_status,
  to_status,
  reason,
  changed_at
)
SELECT
  a.company_id,
  a.id,
  NULL,
  a.status,
  'seeded from application.status during migration',
  COALESCE(a.created_at, NOW())
FROM application a
WHERE NOT EXISTS (
  SELECT 1
  FROM application_status_history ash
  WHERE ash.application_id = a.id
);

INSERT INTO interview_status_history (
  company_id,
  interview_id,
  from_status,
  to_status,
  reason,
  changed_at
)
SELECT
  i.company_id,
  i.id,
  NULL,
  i.status,
  'seeded from interview.status during migration',
  COALESCE(i.created_at, NOW())
FROM interview i
WHERE NOT EXISTS (
  SELECT 1
  FROM interview_status_history ish
  WHERE ish.interview_id = i.id
);
