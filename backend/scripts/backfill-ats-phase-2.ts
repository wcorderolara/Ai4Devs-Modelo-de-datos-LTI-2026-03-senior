import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();
const batchSize = Number(process.env.BACKFILL_BATCH_SIZE ?? "1000");

type LegacyTableConfig = {
  tableName: string;
  idColumn: string;
  createdAtExpression: string;
  updatedAtExpression: string;
};

async function backfillLegacyAuditColumns(config: LegacyTableConfig) {
  let lastId = 0;

  for (;;) {
    const updated = await prisma.$executeRawUnsafe(
      `
        WITH target_rows AS (
          SELECT "${config.idColumn}" AS id
          FROM "${config.tableName}"
          WHERE "${config.idColumn}" > $1
            AND ("createdAt" IS NULL OR "updatedAt" IS NULL)
          ORDER BY "${config.idColumn}"
          LIMIT $2
        )
        UPDATE "${config.tableName}" t
        SET
          "createdAt" = COALESCE(t."createdAt", ${config.createdAtExpression}),
          "updatedAt" = COALESCE(t."updatedAt", ${config.updatedAtExpression})
        FROM target_rows
        WHERE t."${config.idColumn}" = target_rows.id
      `,
      lastId,
      batchSize,
    );

    const nextRows = (await prisma.$queryRawUnsafe<{ id: number }[]>(
      `
        SELECT "${config.idColumn}" AS id
        FROM "${config.tableName}"
        WHERE "${config.idColumn}" > $1
        ORDER BY "${config.idColumn}"
        LIMIT $2
      `,
      lastId,
      batchSize,
    )) as { id: number }[];

    if (nextRows.length === 0) {
      break;
    }

    lastId = nextRows[nextRows.length - 1].id;

    if (updated === 0 && nextRows.length < batchSize) {
      break;
    }
  }
}

async function normalizeStatuses() {
  const statements = [
    `UPDATE employee SET role = UPPER(REPLACE(TRIM(role), ' ', '_')) WHERE role <> UPPER(REPLACE(TRIM(role), ' ', '_'))`,
    `UPDATE interview_flow_version SET status = UPPER(REPLACE(TRIM(status), ' ', '_')) WHERE status <> UPPER(REPLACE(TRIM(status), ' ', '_'))`,
    `UPDATE position SET status = UPPER(REPLACE(TRIM(status), ' ', '_')) WHERE status <> UPPER(REPLACE(TRIM(status), ' ', '_'))`,
    `UPDATE position SET employment_type = UPPER(REPLACE(TRIM(employment_type), ' ', '_')) WHERE employment_type IS NOT NULL AND employment_type <> UPPER(REPLACE(TRIM(employment_type), ' ', '_'))`,
    `UPDATE application SET status = UPPER(REPLACE(TRIM(status), ' ', '_')) WHERE status <> UPPER(REPLACE(TRIM(status), ' ', '_'))`,
    `UPDATE application_status_history SET from_status = UPPER(REPLACE(TRIM(from_status), ' ', '_')) WHERE from_status IS NOT NULL AND from_status <> UPPER(REPLACE(TRIM(from_status), ' ', '_'))`,
    `UPDATE application_status_history SET to_status = UPPER(REPLACE(TRIM(to_status), ' ', '_')) WHERE to_status <> UPPER(REPLACE(TRIM(to_status), ' ', '_'))`,
    `UPDATE interview SET status = UPPER(REPLACE(TRIM(status), ' ', '_')) WHERE status <> UPPER(REPLACE(TRIM(status), ' ', '_'))`,
    `UPDATE interview SET result = UPPER(REPLACE(TRIM(result), ' ', '_')) WHERE result IS NOT NULL AND result <> UPPER(REPLACE(TRIM(result), ' ', '_'))`,
    `UPDATE interview_interviewer SET role = UPPER(REPLACE(TRIM(role), ' ', '_')) WHERE role <> UPPER(REPLACE(TRIM(role), ' ', '_'))`,
    `UPDATE interview_status_history SET from_status = UPPER(REPLACE(TRIM(from_status), ' ', '_')) WHERE from_status IS NOT NULL AND from_status <> UPPER(REPLACE(TRIM(from_status), ' ', '_'))`,
    `UPDATE interview_status_history SET to_status = UPPER(REPLACE(TRIM(to_status), ' ', '_')) WHERE to_status <> UPPER(REPLACE(TRIM(to_status), ' ', '_'))`,
    `
      UPDATE application
      SET closed_at = COALESCE(updated_at, created_at, NOW())
      WHERE closed_at IS NULL
        AND status IN ('HIRED', 'REJECTED', 'WITHDRAWN')
    `,
  ];

  for (const statement of statements) {
    await prisma.$executeRawUnsafe(statement);
  }
}

async function seedApplicationStatusHistory() {
  let lastId = 0;

  for (;;) {
    const rows = (await prisma.$queryRawUnsafe<{ id: number }[]>(
      `
        SELECT id
        FROM application
        WHERE id > $1
        ORDER BY id
        LIMIT $2
      `,
      lastId,
      batchSize,
    )) as { id: number }[];

    if (rows.length === 0) {
      break;
    }

    const ids = rows.map((row) => row.id);

    await prisma.$executeRawUnsafe(
      `
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
        WHERE a.id = ANY($1::int[])
          AND NOT EXISTS (
            SELECT 1
            FROM application_status_history ash
            WHERE ash.application_id = a.id
          )
      `,
      ids,
    );

    lastId = ids[ids.length - 1];
  }
}

async function seedInterviewStatusHistory() {
  let lastId = 0;

  for (;;) {
    const rows = (await prisma.$queryRawUnsafe<{ id: number }[]>(
      `
        SELECT id
        FROM interview
        WHERE id > $1
        ORDER BY id
        LIMIT $2
      `,
      lastId,
      batchSize,
    )) as { id: number }[];

    if (rows.length === 0) {
      break;
    }

    const ids = rows.map((row) => row.id);

    await prisma.$executeRawUnsafe(
      `
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
        WHERE i.id = ANY($1::int[])
          AND NOT EXISTS (
            SELECT 1
            FROM interview_status_history ish
            WHERE ish.interview_id = i.id
          )
      `,
      ids,
    );

    lastId = ids[ids.length - 1];
  }
}

async function main() {
  await backfillLegacyAuditColumns({
    tableName: "Candidate",
    idColumn: "id",
    createdAtExpression: "NOW()",
    updatedAtExpression: "NOW()",
  });

  await backfillLegacyAuditColumns({
    tableName: "Education",
    idColumn: "id",
    createdAtExpression: "NOW()",
    updatedAtExpression: "NOW()",
  });

  await backfillLegacyAuditColumns({
    tableName: "WorkExperience",
    idColumn: "id",
    createdAtExpression: "NOW()",
    updatedAtExpression: "NOW()",
  });

  await backfillLegacyAuditColumns({
    tableName: "Resume",
    idColumn: "id",
    createdAtExpression: `COALESCE("uploadDate"::timestamptz, NOW())`,
    updatedAtExpression: `COALESCE("uploadDate"::timestamptz, NOW())`,
  });

  await normalizeStatuses();
  await seedApplicationStatusHistory();
  await seedInterviewStatusHistory();
}

main()
  .catch(async (error) => {
    console.error(error);
    process.exitCode = 1;
    await prisma.$disconnect();
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
