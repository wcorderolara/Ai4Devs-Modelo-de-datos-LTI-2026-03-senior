# Delivery Document

## Technical Handover and Prompt Delivery Package

| Campo | Valor |
|---|---|
| **Título** | ATS Data Model, SQL, Prompt Engineering and Migration Delivery Document |
| **Subtítulo** | Documento de entrega técnica, funcional y de migración para Applicant Tracking System |
| **Fecha** | 2026-05-11 |
| **Autor** | Codex |
| **Versión** | 1.0 |
| **Stack principal** | PostgreSQL 15+, Prisma ORM, Node.js, TypeScript, Mermaid, Markdown |

> [!IMPORTANT]
> Este documento fue reestructurado en formato de entrega profesional. El contenido técnico fuente se mantiene, y la intervención editorial se limita a organización, navegación y presentación.

**Badges de lectura**

`Enterprise Handover` `ATS` `Data Model` `SQL` `Prisma` `Migration Plan` `Prompt Engineering` `Technical Analysis`

---

## Tabla de Contenido

- [1. Introducción](#1-introducción)
- [2. Arquitectura y Modelo de Datos](#2-arquitectura-y-modelo-de-datos)
- [3. SQL](#3-sql)
- [4. AI / Prompt Engineering](#4-ai--prompt-engineering)
  - [4.1 Conversión de diagrama a SQL](#41-conversión-de-diagrama-a-sql)
  - [4.2 Análisis general de la funcionalidad](#42-análisis-general-de-la-funcionalidad)
  - [4.3 Integración del esquema actual y extensión de los cambios propuestos](#43-integración-del-esquema-actual-y-extensión-de-los-cambios-propuestos)
- [5. Validaciones y Criterios de Calidad](#5-validaciones-y-criterios-de-calidad)
- [6. Riesgos y Notas de Entrega](#6-riesgos-y-notas-de-entrega)

---

# 1. Introducción

[⬆ Volver al índice](#tabla-de-contenido)

## Objetivo del Documento

Este archivo consolida material de modelado, SQL, prompts de análisis, prompts de migración y especificación técnica en un formato navegable y apto para entrega.

## Audiencia Objetivo

- Engineering Managers
- Tech Leads
- Backend Engineers
- Product Owners
- Recruiters técnicos
- Stakeholders no técnicos

## Estado Editorial

- ✅ Contenido técnico preservado
- ✅ Bloques Mermaid preservados
- ✅ Bloques SQL preservados
- ✅ Prompts preservados
- 🟡 Estructura reorganizada para consumo ejecutivo y técnico

---

# 2. Arquitectura y Modelo de Datos

[⬆ Volver al índice](#tabla-de-contenido)

## 2.1 Diagrama fuente del modelo

> [!NOTE]
> El siguiente diagrama Mermaid se conserva exactamente como fue entregado en el contenido fuente.

## 2.2 Diagrama Mermaid

toma el siguiente diagrama
erDiagram
     COMPANY {
         int id PK
         string name
     }
     EMPLOYEE {
         int id PK
         int company_id FK
         string name
         string email
         string role
         boolean is_active
     }
     POSITION {
         int id PK
         int company_id FK
         int interview_flow_id FK
         string title
         text description
         string status
         boolean is_visible
         string location
         text job_description
         text requirements
         text responsibilities
         numeric salary_min
         numeric salary_max
         string employment_type
         text benefits
         text company_description
         date application_deadline
         string contact_info
     }
     INTERVIEW_FLOW {
         int id PK
         string description
     }
     INTERVIEW_STEP {
         int id PK
         int interview_flow_id FK
         int interview_type_id FK
         string name
         int order_index
     }
     INTERVIEW_TYPE {
         int id PK
         string name
         text description
     }
     CANDIDATE {
         int id PK
         string firstName
         string lastName
         string email
         string phone
         string address
     }
     APPLICATION {
         int id PK
         int position_id FK
         int candidate_id FK
         date application_date
         string status
         text notes
     }
     INTERVIEW {
         int id PK
         int application_id FK
         int interview_step_id FK
         int employee_id FK
         date interview_date
         string result
         int score
         text notes
     }

     COMPANY ||--o{ EMPLOYEE : employs
     COMPANY ||--o{ POSITION : offers
     POSITION ||--|| INTERVIEW_FLOW : assigns
     INTERVIEW_FLOW ||--o{ INTERVIEW_STEP : contains
     INTERVIEW_STEP ||--|| INTERVIEW_TYPE : uses
     POSITION ||--o{ APPLICATION : receives
     CANDIDATE ||--o{ APPLICATION : submits
     APPLICATION ||--o{ INTERVIEW : has
     INTERVIEW ||--|| INTERVIEW_STEP : consists_of
     EMPLOYEE ||--o{ INTERVIEW : conducts

---

# 3. SQL

[⬆ Volver al índice](#tabla-de-contenido)

## 3.1 Conversión a SQL

> [!NOTE]
> El siguiente bloque SQL se conserva intacto y se presenta como resultado directo del diagrama previo.

y conviertelo en un script SQL

## Resultado
``` sql
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
```

# 4. AI / Prompt Engineering

[⬆ Volver al índice](#tabla-de-contenido)

## 4.1 Conversión de diagrama a SQL

### Objetivo

Transformar un diagrama entidad-relación Mermaid en un script SQL ejecutable.

### Contexto

El bloque anterior documenta el modelo fuente y su traducción a DDL SQL.

### Uso recomendado

Usar cuando se necesite convertir rápidamente un modelo conceptual a una primera versión relacional.

### Resultado esperado

DDL PostgreSQL legible y alineado con el diagrama proporcionado.


# 4.2 Análisis General de la funcionalidad

[⬆ Volver al índice](#tabla-de-contenido)

> [!IMPORTANT]
> El siguiente prompt se mantiene intacto. Se reorganiza únicamente dentro de una sección editorial de Prompt Engineering.

### Objetivo

Evaluar si el esquema soporta el flujo end-to-end de un ATS multi-tenant en producción.

### Contexto

Este prompt está orientado a análisis crítico de modelo relacional, trazabilidad y escalabilidad.

### Uso recomendado

Usar antes de cerrar diseño de base de datos, antes de pasar a implementación o antes de iniciar migraciones mayores.

### Resultado esperado

Un diagnóstico técnico duro, accionable y orientado a gaps funcionales y operativos.

# PROMPT: Analisis General de la funcionalidad
# ROL

Actúa como un **Senior Database Architect y Domain-Driven Design Practitioner** con más de 15 años de experiencia diseñando sistemas SaaS multi-tenant en producción, especializado en PostgreSQL, modelado relacional avanzado, performance tuning y diseño de esquemas para sistemas ATS / HR-Tech.

# CONTEXTO

Te voy a compartir el DDL de un esquema PostgreSQL correspondiente a un **Applicant Tracking System (ATS)**. El esquema modela compañías, empleados, posiciones laborales, flujos de entrevistas configurables, candidatos, aplicaciones y entrevistas.

Este esquema será la base de un producto SaaS que debe soportar:
- Multi-tenancy (múltiples compañías clientes).
- Alto volumen de aplicaciones y entrevistas concurrentes.
- Trazabilidad y auditoría (compliance laboral).
- Flujos de entrevista altamente configurables por posición.
- Integraciones futuras (job boards, calendarios, video-interviews, scoring por IA).

# OBJETIVO PRINCIPAL ⭐

**Validar que el esquema soporte de extremo a extremo el flujo operativo completo de aplicación de candidatos a múltiples posiciones**, asegurando que cada paso del ciclo de vida sea modelable, consultable, auditable y escalable.

El flujo completo que el esquema **debe** soportar sin fricciones es:

1. **Publicación de posición:** Una compañía publica una o varias posiciones, cada una con su flujo de entrevistas configurado (steps ordenados, tipos de entrevista, entrevistadores asignables).
2. **Descubrimiento y aplicación:** Un candidato existe en el sistema y aplica a **una o varias posiciones** (potencialmente en distintas compañías, o en la misma compañía a distintas posiciones).
3. **Triage inicial:** La aplicación entra en un estado inicial y queda asociada a un flujo de entrevistas heredado de la posición.
4. **Avance por el flujo:** El candidato avanza step-by-step por el flujo de entrevistas; cada entrevista genera resultado, score y notas. Algunos steps pueden requerir múltiples entrevistadores (panel).
5. **Decisiones intermedias:** Rechazo, pausa, reprogramación, repetición de un step, salto de step, o reasignación de entrevistador — todo conservando historial.
6. **Decisión final:** Aceptación (oferta) o rechazo, con trazabilidad de quién decidió, cuándo y por qué.
7. **Consultas operativas críticas:** El esquema debe permitir responder eficientemente:
   - ¿En qué step está cada candidato de una posición?
   - ¿Cuántos candidatos hay en cada etapa del funnel por posición / compañía?
   - ¿Cuál es el time-to-hire promedio por posición?
   - ¿Qué entrevistador tiene más entrevistas pendientes esta semana?
   - Historial completo de un candidato a través de todas sus aplicaciones.
   - Mismo candidato aplicando a múltiples posiciones — ¿se reutiliza su perfil correctamente?
8. **Reapertura y re-aplicación:** Un candidato rechazado puede volver a aplicar a la misma posición meses después, sin perder historial previo.

**Tu análisis debe evaluar críticamente si el esquema soporta cada uno de estos 8 puntos.** Si alguno se rompe, lo modela mal, o requiere workarounds, márcalo explícitamente.

# RESTRICCIONES

- No seas complaciente. Si el flujo se rompe en algún punto, dilo con claridad técnica.
- No repitas el DDL completo; refiérete a las tablas y columnas por nombre.
- Justifica **cada recomendación** con un trade-off (qué se gana, qué se pierde).
- Cuando propongas cambios, entrega DDL ejecutable en PostgreSQL 15+.
- Asume contexto de producción real, no proyecto académico.
- Si una decisión depende de información que no tienes, formula la pregunta de discovery en lugar de asumir.

# FORMATO DE SALIDA

Estructura tu respuesta en estas secciones, en este orden:

## 1. Resumen ejecutivo
3-5 bullets con el veredicto general del esquema, **enfocado en si soporta el flujo completo de aplicación a múltiples posiciones** (listo-para-producción sí/no, principales bloqueadores funcionales).

## 2. Modelo conceptual reconocido
- Entidades principales y su rol.
- Relaciones (1:1, 1:N, N:M) en tabla o lista.
- Diagrama Mermaid (`erDiagram`) del estado actual.
- Patrones de diseño detectados (catálogo, flujo configurable, etc.).

## 3. Validación del flujo end-to-end ⭐ (sección crítica)

Recorre los **8 puntos del flujo operativo** declarados en el OBJETIVO PRINCIPAL. Para cada uno:

- **Punto del flujo:** [nombre].
- **¿Lo soporta el esquema actual?** ✅ Sí / ⚠️ Parcial / ❌ No.
- **Evidencia técnica:** qué tablas/columnas/constraints lo permiten o lo bloquean.
- **Gap encontrado** (si aplica): qué falta para soportarlo limpiamente.
- **Workaround actual vs solución correcta.**

Presta especial atención a:
- ¿Un candidato puede aplicar a N posiciones sin duplicarse? (revisar `candidate` ↔ `application`).
- ¿El historial de un candidato es consultable cross-posición y cross-compañía?
- ¿`UNIQUE (application_id, interview_step_id)` bloquea re-entrevistas legítimas?
- ¿`UNIQUE (position_id, candidate_id)` bloquea reaplicaciones después de rechazo?
- ¿El esquema soporta panel interviews (varios entrevistadores en una misma entrevista)?
- ¿Hay forma de saber el estado actual de una aplicación dentro del flujo sin recomputarlo en cada query?
- ¿`interview_flow` versionado? Si se edita un flujo con aplicaciones en curso, ¿qué pasa?

## 4. Fortalezas del diseño actual
Lista numerada. Solo lo que realmente está bien hecho, con razón técnica.

## 5. Debilidades, riesgos y code smells
Para cada hallazgo:
- **Hallazgo:** descripción.
- **Severidad:** 🔴 Crítico / 🟠 Alto / 🟡 Medio / 🟢 Bajo.
- **Impacto en el flujo operativo:** qué paso del flujo end-to-end se ve afectado.
- **Categoría:** Integridad / Performance / Escalabilidad / Auditoría / Seguridad / Multi-tenancy / Modelado / Mantenibilidad.

Cubre como mínimo:
- Ausencia de timestamps (`created_at`, `updated_at`) y soft deletes — impacto en auditoría del flujo.
- Uso de `VARCHAR` para estados (`application.status`, `interview.result`, `position.status`) vs máquina de estados explícita.
- Multi-tenancy implícita (¿row-level security?, ¿tenant_id propagado en todas las tablas?).
- `ON DELETE CASCADE` vs `RESTRICT`: ¿se pierde historial de aplicaciones al borrar una compañía o posición?
- Índices faltantes para las queries operativas críticas del punto 7 del flujo.
- Constraints faltantes (email, score, fechas coherentes, salario, deadline futuro).
- Falta de auditoría (quién movió la aplicación de step, quién dio el resultado).
- Acoplamiento `position ↔ interview_flow` (1:1 vía `UNIQUE`): ¿permite reutilizar flujos entre posiciones?
- Modelado del resultado de entrevista (`result VARCHAR`): ¿debería ser un workflow/state machine?
- Estado actual de la aplicación dentro del flujo: ¿se deriva o se persiste?
- Internacionalización, monedas en salarios, zonas horarias en fechas.

## 6. Mejoras propuestas (con DDL)
Para cada mejora prioritaria entrega:
- **Problema que resuelve** (referenciando el punto del flujo afectado).
- **Trade-off** (qué cuesta hacerlo).
- **DDL ejecutable** (PostgreSQL 15+), incluyendo migration-safe `ALTER TABLE` cuando aplique.

Ordena las mejoras por **impacto en el flujo operativo end-to-end** (primero las que desbloquean funcionalidad core, luego las de calidad).

Como mínimo cubre propuestas para:
- Versionado de `interview_flow` (snapshot al momento de aplicar).
- Tabla de historial de estados de `application` (audit trail del funnel).
- Soporte para panel interviews (N entrevistadores por entrevista).
- Soporte para re-entrevistas en el mismo step.
- Reaplicación después de rechazo conservando historial.
- Índices para las queries operativas críticas.
- Multi-tenancy explícito y consistente.

## 7. Casos de uso edge no soportados
Escenarios que el esquema actual rompe o modela mal, **enfocados en el flujo operativo real**:
- Reapertura de aplicaciones rechazadas.
- Re-entrevistas en el mismo step (hoy `UNIQUE (application_id, interview_step_id)` lo bloquea).
- Múltiples entrevistadores por entrevista (panel interviews).
- Reasignación de entrevistador conservando historial.
- Candidato aplicando a múltiples posiciones de la misma compañía.
- Candidato aplicando a posiciones de compañías distintas.
- Flujos con steps paralelos u opcionales.
- Versionado de `interview_flow` cuando se modifica con aplicaciones en curso.
- Borrado de compañía → ¿realmente queremos perder todo el historial de candidatos?
- Saltar un step del flujo (fast-track para candidatos referidos).

## 8. Preguntas de discovery para Product/Stakeholders
Lista de 8-12 preguntas que harías antes de cerrar el diseño, **centradas en aclarar las reglas del flujo operativo**. Deben ser preguntas que **desbloquean decisiones de modelado**, no preguntas genéricas.

## 9. Tu opinión profesional (sin filtros)
- ¿Este esquema soporta el flujo end-to-end de aplicación a múltiples posiciones en producción? Sí/No y por qué.
- Si tuvieras que reconstruirlo desde cero hoy, ¿qué 3 cosas harías radicalmente diferente para que el flujo fluya sin fricciones?
- ¿Qué riesgo técnico te quita el sueño con este modelo tal cual está, pensando en el día 1 de producción con miles de aplicaciones simultáneas?

---

# 5. Validaciones y Criterios de Calidad

[⬆ Volver al índice](#tabla-de-contenido)

> [!TIP]
> Los siguientes criterios forman parte integral del prompt y deben conservarse como guía de evaluación y calidad de salida.

---

# 6. Riesgos y Notas de Entrega

[⬆ Volver al índice](#tabla-de-contenido)

> [!WARNING]
> Esta sección final conserva los criterios operativos y de calidad del bloque de migración, relevantes para auditoría técnica, ejecución en producción y handoff entre equipos.

# CRITERIOS DE CALIDAD DE TU RESPUESTA

- **Específico** > genérico. No digas "agregar índices"; di qué índice, en qué columna, para qué query del flujo.
- **Accionable** > teórico. Cada crítica debe venir con una solución.
- **Honesto** > diplomático. Prefiero un análisis duro y útil a uno tibio y bonito.
- **Pragmático** > purista. Considera el costo real de cada cambio en un equipo con deadlines.
- **Flujo-céntrico** > tabla-céntrico. Evalúa cada decisión por cómo afecta la operación real del ATS, no por elegancia de modelado aislada.

---

**Esquema a analizar:**

```sql
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
```

# 4.3 Integración del esquema actual y extensión de los cambios propuestos

[⬆ Volver al índice](#tabla-de-contenido)

> [!WARNING]
> Esta sección contiene un prompt de migración y entrega de alto impacto. El contenido técnico se conserva sin modificaciones.

### Objetivo

Definir un plan Prisma de migración completo, ejecutable y zero-downtime-friendly desde un esquema actual hacia un esquema ATS extendido.

### Contexto

El prompt cubre migraciones, backfills, validaciones, rollback, compatibilidad temporal y modelado final en Prisma.

### Uso recomendado

Usar como prompt maestro para generar handoff de migración, runbook de despliegue y diseño final `schema.prisma`.

### Resultado esperado

Un plan enterprise de migración con fases expand, backfill, switch y contract.

# Integracion del Esquema actual y extension de los cambios propuestos

# ROL

Actúa como un **Senior Backend Engineer y Database Migration Specialist** con más de 10 años de experiencia trabajando con **Prisma ORM en producción**, especializado en PostgreSQL, migraciones zero-downtime, refactors evolutivos de esquemas en sistemas SaaS multi-tenant y modelado de dominios complejos (ATS, HR-Tech, workflows configurables).

Dominas a profundidad:
- Prisma Schema Language (PSL) y todas sus directivas (`@@map`, `@@index`, `@@unique`, `@relation`, `@db.*`, `onDelete`, `onUpdate`).
- `prisma migrate dev`, `prisma migrate deploy`, `prisma migrate resolve` y migraciones manuales con SQL custom.
- Estrategias de migración segura: expand/contract, backfills, dual-writes, feature flags.
- Diferencias entre lo que Prisma puede expresar declarativamente y lo que requiere SQL crudo (CHECK constraints, partial indexes, triggers, RLS, ENUMs nativos vs Prisma enums).

# CONTEXTO

Te voy a entregar **dos artefactos**:

1. **Esquema actual** (DDL SQL de PostgreSQL): el estado vigente de la base de datos de un **Applicant Tracking System (ATS)** multi-tenant.
2. **Esquema propuesto / objetivo** (DDL SQL o descripción estructurada): la versión evolucionada que debe soportar el flujo completo end-to-end de aplicación de candidatos a múltiples posiciones, incluyendo: versionado de flujos de entrevista, panel interviews, re-entrevistas, reaplicaciones, auditoría completa, multi-tenancy explícita, máquinas de estado para `application` e `interview`, e índices para queries operativas críticas.

El proyecto destino usa:
- **Stack:** Node.js + TypeScript + Prisma ORM (última versión estable).
- **Base de datos:** PostgreSQL 15+.
- **Entorno:** Producción real con datos existentes (no se puede truncar).
- **CI/CD:** Las migraciones se aplican con `prisma migrate deploy` en pipeline automatizado.

# OBJETIVO PRINCIPAL ⭐

Producir un **plan de migración Prisma completo, ejecutable y zero-downtime-friendly** que transforme el esquema actual en el esquema propuesto, entregando:

1. El `schema.prisma` final completo y correcto.
2. Las migraciones SQL versionadas, en el orden correcto, divididas en fases seguras (expand → migrate data → contract).
3. Scripts de backfill cuando se requieran transformaciones de datos.
4. Validaciones post-migración.
5. Plan de rollback por cada fase.

# RESTRICCIONES

- **Cero pérdida de datos.** Toda transformación destructiva debe tener backfill previo.
- **Zero-downtime obligatorio.** Nada de `DROP COLUMN` o `RENAME` directos sin estrategia expand/contract.
- **Compatibilidad hacia atrás temporal.** Durante la migración, código viejo y nuevo deben poder coexistir.
- **Prisma-first cuando se pueda, SQL crudo cuando se deba.** Declara en Prisma todo lo expresable; usa `migration.sql` manual para lo que Prisma no soporta (CHECK constraints, partial indexes, triggers, RLS, funciones).
- **Naming convention consistente:** snake_case en DB (`@@map`, `@map`), camelCase en el modelo Prisma.
- **Nombres de migración descriptivos** siguiendo convención `YYYYMMDDHHMMSS_descripcion_en_snake_case`.
- Si una decisión depende de información que no tienes (volumetría, ventanas de mantenimiento, tolerancia a downtime parcial), declara el supuesto explícitamente antes de proponer la solución.

# FORMATO DE SALIDA

Estructura tu respuesta en estas secciones, en este orden:

## 1. Resumen ejecutivo de la migración
- Total de migraciones a generar y orden de ejecución.
- Cambios de alto impacto (breaking vs no-breaking).
- Estimación de complejidad y riesgo (🟢 / 🟡 / 🟠 / 🔴) por fase.
- Supuestos asumidos.

## 2. Diff estructural entre esquema actual y propuesto

Tabla comparativa con columnas:
| Entidad | Cambio | Tipo | Riesgo | Estrategia |
|---|---|---|---|---|

Tipos posibles: `ADD_TABLE`, `ADD_COLUMN`, `DROP_COLUMN`, `RENAME_COLUMN`, `CHANGE_TYPE`, `ADD_FK`, `DROP_FK`, `ADD_INDEX`, `ADD_CONSTRAINT`, `ADD_ENUM`, `CONVERT_VARCHAR_TO_ENUM`, `ADD_JUNCTION_TABLE`, `RELAX_UNIQUE`, `ADD_TENANT_COLUMN`, etc.

## 3. `schema.prisma` final completo

Entrega el archivo Prisma completo y listo para usar, con:
- `datasource` y `generator` configurados.
- Todos los modelos, enums, relaciones, índices, constraints expresables en PSL.
- Comentarios `///` documentando decisiones no obvias.
- Uso correcto de `@@map`, `@map`, `@db.VarChar(n)`, `@db.Decimal(p,s)`, `@db.Date`, `@updatedAt`, etc.
- `onDelete` y `onUpdate` explícitos en cada relación.

## 4. Plan de migración por fases (expand → migrate → contract)

Para cada fase declara:
- **Objetivo de la fase.**
- **Migraciones incluidas** (nombres descriptivos).
- **Reversibilidad.**
- **Compatibilidad con código viejo.**

### FASE 1 — Expand (cambios aditivos no-breaking)
Nuevas tablas, nuevas columnas nullables, nuevos índices, nuevos enums. Nada se rompe.

### FASE 2 — Backfill (transformación de datos)
Scripts para poblar nuevas columnas, normalizar valores, migrar `VARCHAR` a `ENUM`, propagar `tenant_id`, etc.

### FASE 3 — Switch (despliegue del código nuevo)
Marcador lógico: el código de la app empieza a leer/escribir el modelo nuevo.

### FASE 4 — Contract (limpieza de lo viejo)
Drop de columnas obsoletas, drop de constraints viejos, relajación de uniques, aplicación de NOT NULL en columnas backfilleadas.

## 5. Migraciones SQL ejecutables

Para **cada migración**, entrega un bloque con este formato:

```
### Migración: YYYYMMDDHHMMSS_nombre_descriptivo
**Fase:** [Expand | Backfill | Contract]
**Riesgo:** 🟢/🟡/🟠/🔴
**Reversible:** Sí/No (justificar)
**Bloquea tabla:** Sí/No + duración estimada
**Pre-requisitos:** [otras migraciones que deben correr antes]

#### SQL Up
```sql
-- DDL ejecutable
```

#### SQL Down (rollback)
```sql
-- DDL inverso
```

#### Notas
- Justificación técnica.
- Cuándo aplicarla (ventana de mantenimiento sí/no).
- Validaciones a correr antes/después.
```

Incluye obligatoriamente migraciones para:
- Creación de **enums** (`ApplicationStatus`, `InterviewResult`, `PositionStatus`, etc.) con conversión segura desde `VARCHAR`.
- **Versionado de `interview_flow`** (snapshot al momento de aplicar).
- Tabla **`application_status_history`** para audit trail del funnel.
- Tabla **`interview_interviewer`** (junction N:M) para panel interviews.
- Relajación del `UNIQUE (application_id, interview_step_id)` para soportar re-entrevistas.
- Relajación del `UNIQUE (position_id, candidate_id)` para soportar reaplicaciones (o cambio a UNIQUE parcial por estado).
- Adición de `created_at`, `updated_at`, `deleted_at` en todas las entidades relevantes.
- Adición de `tenant_id` / `company_id` propagado donde haga falta para multi-tenancy explícita.
- Índices para queries operativas críticas (estado actual por posición, funnel por compañía, entrevistas pendientes por empleado, historial de candidato).
- CHECK constraints (score, fechas coherentes, salario, deadline).
- Conversión de `ON DELETE CASCADE` a estrategias soft-delete donde se pierda historial valioso.

## 6. Scripts de backfill

Para cada transformación de datos no trivial, entrega:
- Query SQL o script TypeScript con Prisma Client.
- Estrategia para volúmenes grandes (batches, `LIMIT`/`OFFSET` con cursor, transacciones por lotes).
- Idempotencia garantizada.
- Validación previa y posterior.

## 7. Validaciones post-migración

Queries SQL para verificar que la migración fue exitosa:
- Conteos antes/después.
- Detección de huérfanos.
- Verificación de constraints.
- Verificación de que ninguna fila quedó con valores inválidos en los nuevos enums.

## 8. Plan de rollback

Para cada fase, estrategia de rollback:
- ¿Reversible con `migrate resolve --rolled-back`?
- ¿Requiere migración de compensación?
- ¿Qué datos se perderían si se hace rollback después del backfill?

## 9. Checklist de despliegue

Lista accionable paso a paso:
1. Pre-deploy: backups, snapshots, validaciones.
2. Deploy de FASE 1.
3. Ejecución de backfills.
4. Deploy de código nuevo.
5. Deploy de FASE 4.
6. Smoke tests post-deploy.
7. Criterios de éxito y de rollback.

## 10. Riesgos residuales y recomendaciones

- Qué partes de la migración tienen riesgo inherente y no se puede eliminar (solo mitigar).
- Recomendaciones de monitoreo durante y después del deploy.
- Deuda técnica que queda pendiente y debería atacarse en sprints posteriores.

# CRITERIOS DE CALIDAD DE TU RESPUESTA

- **Ejecutable** > descriptivo. Cada SQL debe poder correrse tal cual.
- **Específico** > genérico. Nombres reales de tablas, columnas, constraints, índices.
- **Seguro** > rápido. Prefiere más migraciones pequeñas que una grande peligrosa.
- **Prisma-idiomático** > SQL crudo innecesario. Pero SQL crudo donde Prisma no llega.
- **Honesto sobre límites.** Si algo no se puede hacer zero-downtime, dilo y propón la mejor alternativa.
- **Reproducible.** Cualquier ingeniero del equipo debe poder ejecutar tu plan sin contexto adicional.

---

**Esquema actual:**

```sql
CREATE TABLE "Candidate" (
  "id" SERIAL PRIMARY KEY,
  "firstName" VARCHAR(100) NOT NULL,
  "lastName" VARCHAR(100) NOT NULL,
  "email" VARCHAR(255) NOT NULL UNIQUE,
  "phone" VARCHAR(15),
  "address" VARCHAR(100)
);

CREATE TABLE "Education" (
  "id" SERIAL PRIMARY KEY,
  "institution" VARCHAR(100) NOT NULL,
  "title" VARCHAR(250) NOT NULL,
  "startDate" TIMESTAMP(3) NOT NULL,
  "endDate" TIMESTAMP(3),
  "candidateId" INTEGER NOT NULL,

  CONSTRAINT "Education_candidateId_fkey"
    FOREIGN KEY ("candidateId")
    REFERENCES "Candidate"("id")
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);

CREATE TABLE "WorkExperience" (
  "id" SERIAL PRIMARY KEY,
  "company" VARCHAR(100) NOT NULL,
  "position" VARCHAR(100) NOT NULL,
  "description" VARCHAR(200),
  "startDate" TIMESTAMP(3) NOT NULL,
  "endDate" TIMESTAMP(3),
  "candidateId" INTEGER NOT NULL,

  CONSTRAINT "WorkExperience_candidateId_fkey"
    FOREIGN KEY ("candidateId")
    REFERENCES "Candidate"("id")
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);

CREATE TABLE "Resume" (
  "id" SERIAL PRIMARY KEY,
  "filePath" VARCHAR(500) NOT NULL,
  "fileType" VARCHAR(50) NOT NULL,
  "uploadDate" TIMESTAMP(3) NOT NULL,
  "candidateId" INTEGER NOT NULL,

  CONSTRAINT "Resume_candidateId_fkey"
    FOREIGN KEY ("candidateId")
    REFERENCES "Candidate"("id")
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);
```

**Esquema propuesto / objetivo:**

```sql
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
```

---

[⬆ Volver al índice](#tabla-de-contenido)

**Fin del documento de entrega**

- Estado: 🟡 Draft reestructurado
- Uso recomendado: handoff técnico, revisión de arquitectura, base de onboarding y exportación a PDF/Confluence/Notion
