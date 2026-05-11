# ATS Zero-Downtime Migration Plan

## 1. Resumen ejecutivo de la migracion

- Total de migraciones SQL: `7`
- Orden:
  1. `20260511090000_expand_legacy_candidate_tables_with_audit_columns`
  2. `20260511091000_create_ats_core_tables_with_varchar_statuses`
  3. `20260511092000_add_ats_indexes_constraints_and_updated_at_triggers`
  4. `20260511093000_backfill_legacy_audit_columns_and_seed_status_history`
  5. `20260511094000_convert_status_columns_to_native_enums`
  6. `20260511095000_switch_legacy_candidate_tables_to_snake_case_with_compat_views`
  7. `20260511100000_contract_drop_legacy_compatibility_views_and_finalize_constraints`
- End-state Prisma schema: `backend/prisma/schema.prisma`
- Backfill operacional: `backend/scripts/backfill-ats-phase-2.ts`

### Riesgo por fase

- Fase 1 Expand: `🟡`
- Fase 2 Backfill: `🟠`
- Fase 3 Switch: `🟠`
- Fase 4 Contract: `🟡`

### Supuestos

- La base actual en produccion solo contiene datos en `Candidate`, `Education`, `WorkExperience` y `Resume`.
- No existe todavia trafico de negocio en tablas ATS nuevas, por lo que su creacion e indexacion no requiere `CREATE INDEX CONCURRENTLY`.
- `Candidate` es una identidad global y la tenencia explicita empieza en `application`, `position`, `employee`, `interview_flow` e `interview`.
- Durante el switch puede convivir codigo viejo y nuevo porque las tablas legacy quedan expuestas via views compatibles.

## 2. Diff estructural resumido

| Entidad | Cambio | Tipo | Riesgo | Estrategia |
|---|---|---|---|---|
| `Candidate` | audit columns + rename a `candidate` | `ADD_COLUMN` + `RENAME_TABLE` + `RENAME_COLUMN` | 🟠 | expand audit, switch con views legacy, contract final |
| `Education` | audit columns + rename a `education` | `ADD_COLUMN` + `RENAME_TABLE` + `RENAME_COLUMN` | 🟠 | expand audit, validar checks al final |
| `WorkExperience` | audit columns + rename a `work_experience` | `ADD_COLUMN` + `RENAME_TABLE` + `RENAME_COLUMN` | 🟠 | expand audit, validar checks al final |
| `Resume` | audit columns + rename a `resume` | `ADD_COLUMN` + `RENAME_TABLE` + `RENAME_COLUMN` | 🟠 | expand audit, switch con views |
| `company` | nueva tabla | `ADD_TABLE` | 🟢 | create table |
| `employee` | nueva tabla multi-tenant | `ADD_TABLE` | 🟢 | create table, luego enum `role` |
| `interview_flow` | versionable y multi-tenant | `ADD_TABLE` | 🟢 | create table |
| `interview_flow_version` | snapshot versionado | `ADD_TABLE` | 🟡 | create table + enum `status` |
| `interview_type` | catalogo global | `ADD_TABLE` | 🟢 | create table |
| `interview_step` | pasos por version | `ADD_TABLE` | 🟡 | create table + unique por orden |
| `position` | flujo activo + metadata laboral | `ADD_TABLE` | 🟡 | create table, checks de salario/deadline, enum `status` |
| `application` | snapshot flow version + reapplications | `ADD_TABLE` + `RELAX_UNIQUE` | 🟠 | partial unique por `closed_at IS NULL` |
| `application_status_history` | auditoria de estados | `ADD_TABLE` | 🟢 | create table + seed idempotente |
| `interview` | reentrevistas por `attempt_number` | `ADD_TABLE` + `RELAX_UNIQUE` | 🟠 | unique triple `(application_id, interview_step_id, attempt_number)` |
| `interview_interviewer` | panel interviews N:M | `ADD_JUNCTION_TABLE` | 🟢 | create table |
| `interview_status_history` | auditoria de entrevistas | `ADD_TABLE` | 🟢 | create table + seed idempotente |
| estados `VARCHAR` | enums nativos PostgreSQL | `CONVERT_VARCHAR_TO_ENUM` | 🟡 | normalizar texto, convertir con `USING CASE` |

## 3. Schema final

El source of truth del end-state esta en `backend/prisma/schema.prisma`.

Incluye:

- multi-tenancy explicita en tablas operativas
- soft-delete por `deleted_at`
- auditoria de `created_at` y `updated_at`
- `application_status_history` e `interview_status_history`
- `interview_interviewer` para panel interviews
- `attempt_number` para reentrevistas
- `interview_flow_version` y snapshot en `application.interview_flow_version_id`
- enums nativos de PostgreSQL para estados y roles

## 4. Plan por fases

### Fase 1 Expand

- Objetivo: solo cambios aditivos.
- Migraciones:
  - `20260511090000_expand_legacy_candidate_tables_with_audit_columns`
  - `20260511091000_create_ats_core_tables_with_varchar_statuses`
  - `20260511092000_add_ats_indexes_constraints_and_updated_at_triggers`
- Compatibilidad con codigo viejo: completa.

### Fase 2 Backfill

- Objetivo: poblar audit columns, normalizar estados y sembrar historiales.
- Ejecutar:
  - `20260511093000_backfill_legacy_audit_columns_and_seed_status_history`
  - `ts-node backend/scripts/backfill-ats-phase-2.ts`
- Compatibilidad con codigo viejo: completa.

### Fase 3 Switch

- Objetivo: mover el runtime al esquema nuevo.
- Migraciones:
  - `20260511094000_convert_status_columns_to_native_enums`
  - `20260511095000_switch_legacy_candidate_tables_to_snake_case_with_compat_views`
- Compatibilidad con codigo viejo: mantenida via views `"Candidate"`, `"Education"`, `"WorkExperience"` y `"Resume"`.

### Fase 4 Contract

- Objetivo: eliminar compatibilidad temporal y endurecer constraints.
- Migraciones:
  - `20260511100000_contract_drop_legacy_compatibility_views_and_finalize_constraints`
- Compatibilidad con codigo viejo: no, debe ejecutarse solo tras drenar versiones legacy.

## 5. Validaciones post-migracion

### Conteos

```sql
SELECT 'candidate' AS entity, COUNT(*) FROM candidate
UNION ALL
SELECT 'education', COUNT(*) FROM education
UNION ALL
SELECT 'work_experience', COUNT(*) FROM work_experience
UNION ALL
SELECT 'resume', COUNT(*) FROM resume;
```

### Huerfanos

```sql
SELECT e.id
FROM education e
LEFT JOIN candidate c ON c.id = e.candidate_id
WHERE c.id IS NULL;
```

```sql
SELECT w.id
FROM work_experience w
LEFT JOIN candidate c ON c.id = w.candidate_id
WHERE c.id IS NULL;
```

```sql
SELECT r.id
FROM resume r
LEFT JOIN candidate c ON c.id = r.candidate_id
WHERE c.id IS NULL;
```

### Estados invalidos antes de enum conversion

```sql
SELECT DISTINCT status
FROM application
WHERE status NOT IN (
  'SUBMITTED',
  'IN_REVIEW',
  'INTERVIEW_SCHEDULED',
  'INTERVIEW_IN_PROGRESS',
  'OFFER_EXTENDED',
  'HIRED',
  'REJECTED',
  'WITHDRAWN'
);
```

### Partial unique para reapplications

```sql
SELECT company_id, position_id, candidate_id, COUNT(*)
FROM application
WHERE deleted_at IS NULL AND closed_at IS NULL
GROUP BY company_id, position_id, candidate_id
HAVING COUNT(*) > 1;
```

## 6. Rollback operativo

- Fase 1: reversible con migraciones compensatorias. Riesgo bajo porque todo es aditivo.
- Fase 2: no totalmente reversible; revertir significa perder audit trail sintetico y seeds de history.
- Fase 3: rollback requiere recrear schema legacy visible y volver al codigo viejo. Las views hacen este punto mucho mas seguro.
- Fase 4: rollback implica recrear views legacy y relajar `NOT NULL`.

## 7. Checklist de despliegue

1. Tomar snapshot fisico o backup logico antes de `migrate deploy`.
2. Verificar que no existan filas invalidas para los checks de fechas.
3. Ejecutar Fase 1 en pipeline.
4. Ejecutar Fase 2 fuera de la transaccion de Prisma.
5. Validar conteos, huerfanos y estados.
6. Ejecutar Fase 3.
7. Desplegar codigo nuevo.
8. Confirmar que no quedan pods/instancias con binario viejo.
9. Ejecutar Fase 4.
10. Repetir smoke tests y monitorear errores de DB/ORM.

## 8. Riesgos residuales

- El switch de tablas legacy a snake_case toma locks breves de metadata.
- La conversion a enums fallara si aparecio un valor libre fuera del catalogo permitido entre backfill y switch.
- Si el codigo viejo sigue activo despues de Fase 4, perdera compatibilidad al desaparecer las views.
