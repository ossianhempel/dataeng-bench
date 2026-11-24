## Schema (PostgreSQL)

```sql
CREATE EXTENSION IF NOT EXISTS btree_gist;

CREATE TABLE patient (
    patient_id    BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name     TEXT NOT NULL,
    date_of_birth DATE NOT NULL,
    email         TEXT NOT NULL UNIQUE,
    phone         TEXT NOT NULL,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE clinic (
    clinic_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name      TEXT NOT NULL UNIQUE,
    address   TEXT NOT NULL,
    time_zone TEXT NOT NULL            -- IANA name, e.g. 'Europe/Stockholm'
);

CREATE TABLE room (
    room_id   BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    clinic_id BIGINT NOT NULL REFERENCES clinic,
    name      TEXT NOT NULL,
    UNIQUE (clinic_id, name)
);

CREATE TABLE clinician (
    clinician_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name    TEXT NOT NULL,
    email        TEXT NOT NULL UNIQUE
);

CREATE TABLE specialty (
    specialty_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name         TEXT NOT NULL UNIQUE
);

CREATE TABLE clinician_specialty (
    clinician_id BIGINT NOT NULL REFERENCES clinician,
    specialty_id BIGINT NOT NULL REFERENCES specialty,
    PRIMARY KEY (clinician_id, specialty_id)
);

CREATE TABLE clinician_clinic (
    clinician_id BIGINT NOT NULL REFERENCES clinician,
    clinic_id    BIGINT NOT NULL REFERENCES clinic,
    PRIMARY KEY (clinician_id, clinic_id)
);

CREATE TABLE availability (
    availability_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    clinician_id    BIGINT NOT NULL,
    clinic_id       BIGINT NOT NULL,
    period          TSTZRANGE NOT NULL,
    FOREIGN KEY (clinician_id, clinic_id) REFERENCES clinician_clinic,
    -- a clinician cannot be available at two clinics at once
    EXCLUDE USING gist (clinician_id WITH =, period WITH &&)
);

CREATE TABLE appointment_type (
    appointment_type_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name                TEXT NOT NULL UNIQUE,
    specialty_id        BIGINT REFERENCES specialty,
    default_minutes     INT NOT NULL CHECK (default_minutes > 0),
    default_price       NUMERIC(10, 2) NOT NULL CHECK (default_price >= 0)
);

CREATE TABLE appointment (
    appointment_id      BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    patient_id          BIGINT NOT NULL REFERENCES patient,
    clinician_id        BIGINT NOT NULL REFERENCES clinician,
    room_id             BIGINT NOT NULL REFERENCES room,
    appointment_type_id BIGINT NOT NULL REFERENCES appointment_type,
    starts_at           TIMESTAMPTZ NOT NULL,
    ends_at             TIMESTAMPTZ NOT NULL,
    price               NUMERIC(10, 2) NOT NULL CHECK (price >= 0),  -- price agreed at booking
    status              TEXT NOT NULL DEFAULT 'booked'
                        CHECK (status IN ('booked', 'completed', 'cancelled', 'no_show')),
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    CHECK (ends_at > starts_at),
    EXCLUDE USING gist (clinician_id WITH =, tstzrange(starts_at, ends_at) WITH &&)
        WHERE (status <> 'cancelled'),
    EXCLUDE USING gist (room_id WITH =, tstzrange(starts_at, ends_at) WITH &&)
        WHERE (status <> 'cancelled')
);

CREATE TABLE appointment_event (
    event_id         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    appointment_id   BIGINT NOT NULL REFERENCES appointment,
    event_type       TEXT NOT NULL CHECK (event_type IN ('booked', 'rescheduled', 'cancelled', 'completed', 'no_show')),
    occurred_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    actor_type       TEXT NOT NULL CHECK (actor_type IN ('patient', 'clinician', 'staff', 'system')),
    actor_id         BIGINT,
    reason           TEXT,
    previous_starts_at TIMESTAMPTZ,
    previous_ends_at   TIMESTAMPTZ,
    previous_room_id   BIGINT REFERENCES room
);
```

## Key decisions

- **Many-to-many relationships** (clinician-specialty, clinician-clinic) are junction
  tables with composite primary keys. Availability references `clinician_clinic`, so a
  clinician can only publish hours at a clinic they work at.
- **Double-booking** is prevented in the database with two exclusion constraints on
  `tstzrange(starts_at, ends_at)`: one per clinician and one per room. The partial
  `WHERE status <> 'cancelled'` frees the slot when an appointment is cancelled.
  Application checks alone race under concurrent bookings.
- **History**: the appointment row holds the current state; every change writes an
  `appointment_event` row with who, when, why and the previous slot. Reschedule rate is
  `count(*) FILTER (WHERE event_type = 'rescheduled')` per appointment. Rows are never
  deleted.
- **Time**: all instants are `TIMESTAMPTZ` (stored in UTC); the clinic's IANA time zone
  is used for display and for availability rules. `ends_at` is stored rather than derived
  from the type's default duration, because a clinician can extend a slot.
- **Normalization**: patient, clinician and clinic attributes live only in their own
  tables. `price` on the appointment is the price agreed at booking, not a copy of the
  current list price, so it is a fact of the appointment.

## Trade-offs

- Exclusion constraints versus a slot table (`(clinician_id, slot_start)` unique, 15-minute
  slots): the slot table works on any database but forces a fixed granularity and many rows
  per appointment. I chose exclusion constraints because the target is PostgreSQL.
- Event table versus versioned appointment rows (SCD-style): the event table keeps the
  current appointment simple to query and makes "who cancelled and why" explicit.
- Room is chosen at booking time rather than derived from availability, which keeps
  availability simple but needs the room exclusion constraint.
