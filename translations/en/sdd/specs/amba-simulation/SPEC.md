> Automatic English translation of [`sdd/specs/amba-simulation/SPEC.md`](../../../../../sdd/specs/amba-simulation/SPEC.md)
> at commit `05dc1e1`. The Spanish original prevails.

# SPEC · Geolocated simulation of the AMBA: projection with little data

Status: **real 2023 data decided by the author on 31/10/2026; S-1, S-2 and S-3
pending. First prototype built with the ★ options as provisional, at the author's
request of 31/10/2026 (see Implementation).** Axis: **D. Election day and vote count (jornada y escrutinio)** of the [vision](../../../../../sdd/specs/vision/SPEC.md),
the visible closing of the process.

## Goal

Show, on a map of the Buenos Aires Metropolitan Area (AMBA), how party poll watchers
(fiscales) enter telegrams and how a projection of the result stabilizes with very little
data. **A real, already finished election is replayed** (2023 general election) for the
hackathon demo and to explain why every entry counts.

## Author's decision · 31/10/2026

The previous version required synthetic data only. The author clarified that this was a mistake
and that he never authorized it. From now on:

- **Data:** official results **per polling table (mesa)** of the general election of
  **22/10/2023**, category **President and Vice President**.
- **Region:** **CABA + 24 districts (partidos)** of the Greater Buenos Aires suburbs (conurbano) (answers Q2).
- **Sample telegrams and tally sheets (actas):** in addition to the results, a sample of official
  2023 images from the AMBA to show what is captured and to test data entry.
  They contain names and signatures of polling-table officials (autoridades de mesa) and poll
  watchers: they are stored in `data/private/`, never in Git, and are not shown in public without
  redacting that data (Law 25.326 (Ley 25.326)). The per-polling-table results contain no personal data.
- **Presentation:** in the demo the political forces are shown as **List A/B/C…** (option
  chosen by the author). The mapping to the real forces stays in the data, off
  the screen.

## Scope

1. Map of the AMBA (CABA and the 24 districts) with the polling places or the electoral sections
   and circuits as points.
2. **Real 2023 data:** registered voters, voters who turned out and votes per political grouping
   (agrupación), blank and null votes for each polling table, with their provenance (official URL,
   download date and SHA-256 of the file). What is downloaded is not modified; normalization produces a
   derived, reproducible file. The sample of telegrams and tally sheets stores the same
   (URL, polling table, date and SHA-256) per image.
3. Arrival of entries over time, with configurable speed and **arrival bias**
   (for example, CABA reports before the third ring (tercer cordón)).
4. Live projection:
   - naive: simple sum of the entered polling tables;
   - stratified: by municipality or section, weighted by registered voters;
   - with a confidence interval that narrows as data arrives.
5. Panel: % of polling tables entered, projection vs. **official 2023 result of the same
   polling tables**, error and interval width. Play, pause, speed and seed
   controls.
6. Reproducible: the same seed produces the same arrival order.
7. The screen shows at all times "SIMULACIÓN · reproducción de las generales 2023"
   ("SIMULATION · replay of the 2023 general election").

Out of scope: bulk image download, prediction of future elections,
integration with the app.

## Pending decisions

| ID | Decision | Options |
| --- | --- | --- |
| S-1 | Platform | Static web (MapLibre GL + JS, no backend) · Python notebook · SwiftUI MapKit |
| S-2 | Geography | Official polygons of districts and communes (IGN, open data from CABA/PBA) · points inside each polygon · real polling places if there is a public dataset (see Q1) |
| S-3 | Statistical model | Stratified by municipality with intervals (proposal) · post-stratified with regression · hierarchical Bayesian |

Recommendation: S-1 static web (it can be shown on a projector, anyone can
open it with a link and it requires installing nothing on the phone); S-2 official polygons;
S-3 stratified, which can be explained in one minute.

Storage proposal (to be confirmed by the author): the downloaded official files
stay in `data/private/` (outside Git, due to size), and in Git only a
manifest with URL, date and SHA-256 and the script that normalizes them.

## Legal restriction

The Electoral Code (Código Electoral) (art. 71 subsec. h) prohibits publishing projections during
the election and until three hours after the polls close. The 2023 replay is not
covered because that election is over, but it must not be presented as a projection of
an ongoing election. Any use with real data on election day must
respect that window. Pending: `electoral_counsel` check of this change.

## Provisional implementation · 31/10/2026

With the ★ recommendations as provisional until #3 is answered:

- **Data:** DINE, *Resultados provisorios Elecciones 2023 - Generales*
  (`https://www.argentina.gob.ar/sites/default/files/2023_generales_1.zip`,
  SHA-256 `2562b18c741ba5740d264e5328f206cb25f709ed0a4f8cf962f301e423e79c6b`,
  downloaded on 31/10/2026). It is the **provisional count (escrutinio provisorio)**; the final
  count (escrutinio definitivo) remains pending. `scripts/amba-simulation/normalize.py` generates
  `data/private/amba-simulation/mesas_2023_amba.json`: 29,962 polling tables, 39 strata
  (15 communes + 24 districts), 10,413,971 registered voters. Lists A–E by ascending
  `agrupacion_id`.
- **Geography (provisional S-2):** district polygons from PBA open data
  (`limite-partidos-pba.zip`, CC BY 4.0) and communes from CABA open data
  (`comunas.geojson`). Generated by `scripts/amba-simulation/geography.py`. There are
  also PBA electoral circuit polygons, for a finer-grained version.
- **Platform (provisional S-1):** static page
  `design/prototypes/simulacion-amba/index.html`. It draws the map in its own SVG, without
  MapLibre or tiles, so it runs offline with no dependencies. It reads the data from
  `data/private/` with a local server or takes it from files chosen by hand.
- **Model (provisional S-3):** separate ratio estimator by registered voters in each
  stratum, with a 95 % interval by linearization. Strata without data are imputed
  with the global ratio. The arrival bias delays the first ring and the second one even more
  (approximate INDEC classification).
- **Measurement (30 seeds, percentages over affirmative votes):**

  | Bias | Polling tables | Max. naive error (median) | Max. stratified error (median) | Stratified < 2 pts |
  | --- | --- | --- | --- | --- |
  | 0 | 5 % | 0.28 | 0.24 | 30/30 |
  | 0.7 | 5 % | 3.08 | 0.22 | 30/30 |
  | 1 | 5 % | 3.93 | 0.18 | 30/30 |
  | 1 | 2 % | 4.00 | 0.35 | 30/30 |

  Criteria 1 and 2 are met in the simulation.
- **Coverage of the 95 % interval** (40 seeds × 5 lists per scenario): 92.5 % with no
  bias and 5 % of polling tables; 96.0 % with bias 0.7 and 5 %; 93.5 % with no bias and 2 %; 95.5 % with
  bias 0.7 and 10 %. It stays close to nominal, slightly below with unbiased
  samples, because polling tables in the same circuit resemble each other.
  Criterion 4 is pending: the totals still need to be checked against the published ones.
- Downloads and derived files stay in `data/private/`, outside Git. Git holds
  the scripts, the prototype and this provenance.

## Acceptance criteria

1. With 5 % of polling tables entered with no bias, the stratified projection stays
   within 2 points of the official 2023 result in most seeds (to be measured).
2. With arrival bias, the demo shows that the naive sum drifts and the
   stratified one does not.
3. Runs offline from a file or a link.
4. The per-party sums and totals of the normalized file match the official totals
   published for the AMBA.
5. Neutrality: the same method and the same metrics apply to all political forces.

## Open questions

- Q1. Is there a public dataset of 2023 polling places with coordinates and
  number of polling tables? Assign to electoral_analyst.
- Q2. Answered by the author: CABA + 24 districts.
