> Automatic English translation of [`sdd/specs/fiscal-planning/SPEC.md`](../../../../../sdd/specs/fiscal-planning/SPEC.md)
> at commit `5754b3d`. The Spanish original prevails.

# SPEC · Planning mode for poll watchers covering several polling tables

Status: **proposal for the app design; pending prototype and author acceptance.**
Axis: **D. Election day and vote count (jornada y escrutinio)** of the [vision](../../../../../sdd/specs/vision/SPEC.md).
Date: 31/10/2026. Author's request. Depends on [telegram-capture](../telegram-capture/SPEC.md),
[scrutiny-backend](../scrutiny-backend/SPEC.md) and [app-screens](../app-screens/SPEC.md).

## Problem

Political forces with few party poll watchers (fiscales) cannot cover all polling tables (mesas).
The same person goes around several polling places (establecimientos) (general poll watcher
(fiscal general) or a poll watcher covering more than one polling table; role and powers to be
verified with `electoral_counsel`). Today they write down by hand which polling tables they
saw, what is missing and what other people entered. They lose time and polling tables.

The app has to help them plan the day, record what they checked and learn
in time what other people upload about their polling tables.

**Neutrality:** the mode is available equally to any political force, independent poll
watcher or volunteer. No function depends on the party. It is more useful for
whoever covers many polling tables, but the rules are the same for everyone.

## Users

- **Poll watcher covering several polling tables** (main case): from 2 to dozens of polling
  tables, in one or several polling places.
- **Their team's coordination** (optional): assigns polling tables and sees coverage. It only sees
  the people on its own team.

## Scope

1. **Day plan:** choose or receive the polling tables to cover (polling place, polling tables,
   circuit). Sort them by polling place and route. Show the key times:
   opening, closing and vote count (escrutinio) (to be verified against the current schedule).
2. **Status per polling table**, with a single action for each change:
   `pendiente → visitada → escrutinio presenciado → telegrama/acta capturado → cotejado`
   (pending → visited → count witnessed → telegram/tally sheet (acta) captured → cross-checked),
   plus `incidencia` (incident, with a note) and `no cubierta` (not covered).
3. **Check log:** each status change stores the time and, if the person
   wants, a note. It does not store the location by default (see Personal data).
4. **Notifications for followed polling tables:** when another person (poll watcher of another force,
   polling-table official (autoridad de mesa) or volunteer) uploads a capture of a polling table in their plan:
   - notice with polling table, document type and time;
   - if there is already an own entry, the automatic cell-by-cell cross-check: **matches** or
     **there are differences** (with the cells). Use the word "difference", never
     "irregularity";
   - if the polling table is not covered, offer to use that capture as a reference without
     confirming it as their own.
5. **Coverage view:** polling tables in the plan with own capture, with third-party capture
   or with none. Prioritizes those with no capture from anyone.
6. **Offline mode:** the plan, the statuses and the captures work offline. They
   sync when signal returns, with the queue of [scrutiny-backend](../scrutiny-backend/SPEC.md).
7. **Closing summary:** polling tables covered, captures, differences and incidents.
   Exportable with the same personal-data and electoral blackout (veda) notice as the evidence
   package.
8. Local **reminders**: polling-table closing and "te faltan N mesas sin captura" ("you have N polling tables left without a capture").

Out of scope for the first version: turn-by-turn navigation (the system map
is opened), chat between poll watchers, optimal automatic assignment.

## Notifications and backend

- Subscription per polling table: the device registers the polling tables in its plan. API
  proposal to add to [scrutiny-backend](../scrutiny-backend/SPEC.md):
  `PUT /v1/devices/{id}/watchlist` `{mesas:[…]}` and an events channel
  `GET /v1/devices/{id}/events?since=…` (polling; system push as an improvement).
- `capture.received` event for a followed polling table: `{mesa, documentType, receivedAt,
  comparison?:{status: match|differences, cells:[…]}}`. **It does not include the image or
  the identity of the uploader**, unless the author decides otherwise (FP-3).
- Scale: subscriptions are indexed by polling table. A capture event is fanned out to
  N subscribers via a queue, without querying all devices.
- Blackout (veda) (Electoral Code (Código Electoral) art. 71 subsec. h, to be verified): notifications
  are about individual polling tables, sent to whoever follows them, and contain no projections or
  aggregates. `electoral_counsel` must confirm this.

## Personal data (Law 25.326 (Ley 25.326))

- The plan and the location stay **on the phone**. The server only receives the list
  of followed polling tables and the device token, without name, national ID (DNI) or phone number.
- The team sees polling-table statuses, not locations. Sharing the location would be optional,
  explicit and switchable off (FP-4).
- Third-party captures keep the evidence treatment: immutable original,
  separation between what was extracted and what was confirmed.

## Pending decisions

| ID | Decision | Options |
| --- | --- | --- |
| FP-1 | Origin of the plan | The person builds it ★ · their coordination assigns it · both |
| FP-2 | Notifications | Polling on open and every N minutes ★ (prototype) · system push (APNs/FCM) |
| FP-3 | Identity of the uploader of a third-party capture | Anonymous ★ · declared force · pseudonym |
| FP-4 | Location | Never leaves the phone ★ · shared with the coordination by choice |
| FP-5 | Teams | No teams in v1 ★ · teams with invitation code |
| FP-6 | Use of third-party captures on uncovered polling tables | Reference only ★ · can be confirmed as own after review |

## Screens

None is implemented without an approved navigable prototype in `design/prototypes/`
([review-pipeline](../../../../../sdd/specs/review-pipeline/SPEC.md)). Candidate screens: day plan,
polling place detail, polling table detail with statuses, notifications inbox, coverage
and summary. They are integrated into the navigation the author chooses in AS-1.

## Acceptance criteria

1. A person with 12 polling tables in 3 polling places builds their plan in less than 3 minutes.
2. Changing the status of a polling table takes one action and works offline.
3. A third-party capture of a followed polling table generates a notice within 1 minute with
   connection. When there is an own entry, the notice brings the cell-by-cell cross-check.
4. No personal data or location leaves the phone without explicit choice.
5. Same functions and texts for any political force (neutrality review).

## electoral_counsel check: pending

Risks to assess: powers of the general poll watcher and of whoever covers several polling tables;
use of captures from other forces; notices during election day and blackout; treatment of
images with data of polling-table officials.
