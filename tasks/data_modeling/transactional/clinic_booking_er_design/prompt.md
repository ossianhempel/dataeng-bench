# Design a clinic booking database

A company runs several clinics. Design the transactional (OLTP) database behind
its appointment booking app. Requirements:

- Patients sign up with name, date of birth, email and phone. Email is unique.
- Clinicians have one or more specialties (for example physiotherapy,
  dermatology) and can work at more than one clinic.
- Each clinic has an address, a time zone and several treatment rooms.
- Clinicians publish the hours they are available at a given clinic.
- An appointment is for one patient with one clinician, in one room at one
  clinic, for an appointment type (for example "first consultation, 45
  minutes"). Appointment types have a default duration and price.
- A clinician and a room can never be double-booked.
- Appointments can be rescheduled or cancelled. The business needs to know who
  cancelled, when, and why, and how often appointments get rescheduled.

Provide:

1. The tables with columns, data types, primary keys, foreign keys and the
   other constraints you would declare (SQL DDL for PostgreSQL is preferred).
2. A short explanation of the key design decisions, including how you prevent
   double-booking and how you keep cancellation and reschedule history.
3. At least one trade-off you made and the alternative you rejected.
