> Automatic English translation of [`sdd/specs/network-governance/SPEC.md`](../../../../../sdd/specs/network-governance/SPEC.md)
> at commit `3e38eb7`. The Spanish original prevails.

# SPEC · Decentralized governance of the trust network

Status: **proposal (synthesis of the deliberation of 31/10/2026); decisions NG-1 to NG-20
pending from the author.** `electoral_counsel` check: **partial**, via the position
[03-legal-security](../../../../../sdd/specs/network-governance/deliberation/03-legal-security.md) (no independent review); the formal
check of this SPEC is pending. Nothing that follows is a decision: the author decides.

Author's request: "convertir la red en una DAO o algo del estilo, sin control centralizado; bastantes
niveles y dinámicos; diseñar los tipos de interacciones y qué mejora el nivel; evaluaciones
colegiadas de las formas de interactuar con las plataformas corporativas" ("turn the network into a DAO
or something like it, without centralized control; quite a few dynamic levels; design the types of
interactions and what improves the level; collegiate evaluations of the ways of interacting with
corporate platforms"). Synthesized positions:
[01 DAO](../../../../../sdd/specs/network-governance/deliberation/01-dao-governance.md), [02 deliberative democracy](../../../../../sdd/specs/network-governance/deliberation/02-deliberative-democracy.md),
[03 legal and cybersecurity](../../../../../sdd/specs/network-governance/deliberation/03-legal-security.md), [04 trust & safety and neutrality](../../../../../sdd/specs/network-governance/deliberation/04-trust-safety-neutrality.md).
Marks: **[NV]** = source not verified in the originating position; **[I]** = interpretation.

## Scope and relationship with other SPECs

- Resolves **RC-2 and RC-4** of [civic-network](../../../../../sdd/specs/civic-network/SPEC.md) and refines **RC-3**; **DL-2** of
  [civic-deliberation](../../../../../sdd/specs/civic-deliberation/SPEC.md); **TC-2, TC-3, TC-10, TC-15** of
  [trust-chain-identity](../trust-chain-identity/SPEC.md); governs the activation of **A5** of
  [platform-accountability](../../../../../sdd/specs/platform-accountability/SPEC.md); depends on **V-4** ([vision](../../../../../sdd/specs/vision/SPEC.md))
  and PP-2 ([participant-protection](../../../../../sdd/specs/participant-protection/SPEC.md)).
- **It governs only the trust network** (pseudonymous identity, invitations, reputation, deliberation,
  governance). The **tally-sheet (acta) publication network** stays disconnected (TC-13 ★): its rules are set
  before the campaign, they are not voted on during the electoral period and its captures are validated by matching and
  the official count (escrutinio oficial), never by reputation (03 §3.1, 04 §0). Parties: generic role accounts (TC-11 ★, TC-14).
- **The app does not register people** (TC-15, author's clarification): the account is a key and a pseudonym;
  an identified public profile is optional and exposes its subnetwork. This SPEC does not resolve it: it treats it
  as a risk and an open decision (NG-20).
- Inherits the bounded ⛔ of the [trust-chain check](../../../../../sdd/specs/trust-chain-identity/checks/electoral_counsel.md)
  (L2: graph with real people until TC-5/TC-12 are decided and A5 is resolved).

## 1. A DAO? The deliberation's answer

### Consensus among the four positions

1. **DAO principles, not DAO technology:** public, versioned rules, decisions recorded
   verifiably, delays before execution, distributed powers. **No token, no public
   blockchain, no money at stake** (01 §1, 02 §1, 03 §1.4 and §2, 04 thesis 5): a token buys power; an
   immutable public ledger clashes with Law 25.326 (Ley 25.326) (arts. 7, 12, 16).
2. **Verifiable append-only log without personal data** (Merkle tree, Certificate
   Transparency style [NV: RFC 9162, Sigsum]): hashes of rules, versions, aggregated results and moderation
   decisions. Individual votes kept out, encrypted, with limited retention (01 option B, 03 §1.4).
3. **A responsible legal entity** (civil association (asociación civil) or allied CSO) for the database, habeas
   data and external acts; governance decides within its bylaws. "Descentralizar la decisión
   no descentraliza la responsabilidad" ("Decentralizing the decision does not decentralize responsibility")
   (03 §1; 01 [NV: *CFTC v. Ooki DAO*]; 02 §4; 04 §5).
4. **Reputation grants tasks, not votes.** One verified person = one vote (all four).
5. **Progressive decentralization** with phases, measurable criteria and published dates; today control
   lies with the author and that should be stated (01 §3, 02 §1, 03 §1.3). **Separation of powers:** proposing,
   admitting, evaluating, deciding, executing and overseeing do not fall on the same body (02 §1, 04 §3).
6. **Verifiable sortition + public rubric** to evaluate modalities towards platforms, with
   ratification by the network, legal check and the author's decision (all four). **Blackout (veda):** no rule
   changes or external actions during the electoral period (01, 03 G8, 04).

### Explicit disagreements and recommendation

| Topic | 01 | 02 | 03 | 04 | ★ synthesis |
| --- | --- | --- | --- | --- | --- |
| Bridging algorithm / latent perspective factor | Do not use: inferring stances is sensitive data; blind panels | Yes, ephemeral and aggregated per deliberation, with legal check | Political profiling = arts. 2 and 7 | Yes, ephemeral, only as a diversity constraint; ⚠️ high | NG-5: no bridging now; later only with a favorable legal opinion |
| Sensitive roles (moderation, level 3) | Care ≥ z + election | Election or periodic confirmation with mandate | — | Sortition among eligible people with mandate; election rewards blocs | Sortition among eligible people with mandate and confirmation (NG-10) |
| Panel size | 15 + 2 advisors | 15–25 | "sufficient level and distinct branches" | 9–15 | 15 for new modalities, 9 for activations (NG-7) |
| Decay half-life | ~90 days | ~6 months | — | ~90 days | 90 days with a dignity floor; calibrate (NG-16) |
| Emergency brake | k-of-n council (5 of 9), pause ≤ 14 days | — | k-of-n multisig, pause only, report within 24 h | Any sortitioned panel can suspend for a short period | k-of-n council and, in addition, short pause by an ongoing panel (NG-14) |
| Veto during the transition | Author: full → constitution only → none | Founders, temporary and published | Board of directors (comisión directiva): only for unlawfulness, reasoned and public | — | Phase 0 author; phase 1 entity only for unlawfulness; phase 2 no individual veto (NG-8) |
| Anchoring hashes on a public chain | Optional, no data | — | Medium risk (metadata) | Not until after 2027 | Allies' and press sites now; public chain: NG-15 |
| Parties and cross-cutting consensus | k parties support or do not object, m veto | Support from distinct groups/branches | — | Parties do not vote or sit on panels | No vote or veto; a reasoned objection requires a recorded response (§3, §5) |
| Rubric scale | 0–4, eliminatory | 0–3, minimums per criterion | Requirements as acceptance criteria | 0–3 | 0–3 with eliminatory criteria (§4) |

## 2. Reputation and dynamic levels

Name: **participation reputation** (TC-10 ★). Never "token", "credits" or "social credits" (03 §2, 04 §1).

### Unified model

- **Dimensions:** **evidence** (A1–A3), **verification**, **deliberation**, **care** (panels,
  moderation, mentoring, auditing of the network) and **reliability** (absence of sanctions). A high level
  in one dimension grants no permissions in another (01 §2, 04 §1).
- **Base formula, to be calibrated in simulation:** `R_d(t) = Σ_períodos √(puntos del período) · e^(−(t − t_i)/τ)`
  (sum over periods of √(points in the period)) per dimension `d`, half-life ~90 days (NG-16). Diminishing returns (√) and caps against
  volume; decay against lifelong elites and dormant accounts.
- **Visible levels:** `nivel = floor(log2(1 + R_total))`, cap 12 (01; 04 proposes 0–7). They are a summary
  for the person; **permissions depend on per-dimension thresholds**, published, versioned and
  modifiable like any rule (§3). The 0–3 table of TC-2 becomes the four-band summary.
- **Dignity floor:** nobody drops below level 1 due to inactivity if they had no sanctions. **Non-transferable,
  not purchasable, not delegable, with no economic value, not redeemable, outside any blockchain** (03 §2);
  stated in the regulations and the terms of use. **No public ranking, badges or streaks** (NG-11):
  each person sees their score, its breakdown and "why it went up or down", with appeal; what is public is the
  formula and the aggregates.
- **Reputation and public profiles (TC-15, NG-20):** by default reputation is private and pseudonymous.
  If the author enables identified public profiles, the level would only be displayed with an anonymous
  credential ("level ≥ N", TC-8) that does not link the trust account or its subnetwork. Linking accounts from
  other networks to the profile stays outside reputation.
- **Neutrality:** no signal looks at the content of the opinion, the party or which side someone argued on
  (TC criterion 4); cross-verification is measured, not popularity. **Graduated and
  reversible sanctions** (Ostrom [NV]): warning → temporary deduction in the dimension → quarantine → revocation only
  with evidence; every downgrade with a readable reason, appealable before a sortitioned panel from another dimension and
  other branches (art. 20 by analogy [I], 03 §2).

### Core rule

**Reputation grants tasks, not votes.** In consensus decisions, one verified person counts as one vote. Endorsing
an initiative is a right, not a merit: it adds no reputation. Weighting votes by reputation creates an
aristocracy of veterans (01 §2, 02 §2, 04 thesis 2). Quadratic, conviction and liquid
democracy voting: postponed (NG-18).

### Unified catalog of interactions (trust network only)

Initial points to calibrate. "Branch" = invitation subtree; its diversity is measured with counters or
coarse, rotating group identifiers, without opening the graph (A5-b).

| Interaction | Dimension | Adds | Who validates | Cap | Risk |
| --- | --- | --- | --- | --- | --- |
| Read, follow topics | — | 0 | — | — | — |
| Argue for or against with a source | deliberation | +2 | Blind sortitioned panel (no authorship): source, relevance, respect; never the stance. With NG-5 (b), bridging | 10/month | Medium: brigades, tone |
| Amendment incorporated into a consolidated version | deliberation | +3 | Version log; accepted by someone who is not the author | 5/month | Medium: sabotage |
| Structured proposal that reaches a consolidated version | deliberation | +5 | Threshold of verified endorsements + neutrality admission | 2/month | Medium: spam, covert partisan proposal |
| Rate "useful / not useful" | — (adjusts the rater's weight) | 0 | Later agreement with independent verification | — | High: rings, co-voting |
| Endorse an initiative | — | 0 (right) | Verified person | — | High: Sybil, bought endorsements |
| Upload accepted A1–A3 evidence | evidence | +2 | Hash + reproduction by another person from another branch + automatic re-check | 15/month | High: fabrication, false positives |
| A4 finding reproduced with the public methodology | evidence | +5 | Independent reproduction + sample review | 3/month | Medium |
| Verify others' evidence (double blind) | verification | +1 | Matches the majority of independent verifiers; control samples | 40/month | High: collusion |
| Fact-checking with sources (axis B) | verification | +2 | Linked sources + sample sortitioned panel | 10/month | High: partisan "fact-check" |
| Service on a sortitioned panel (opinion delivered) | care | +4 | Panel signature in the log | By sortition | Low |
| Moderation decision confirmed on appeal or sample | care | +1 | Appeal panel | 20/month | Very high: capture (role by sortition) |
| Confirmed mentoring or training | care | +2 | Confirmation by the recipient, from another branch | 5/month | Medium: fake reciprocity |
| Invitee active and without sanctions after 60 days | care | +1 | Counters (does not open the graph) | TC-2 quota | High: farms |
| Confirmed finding of bias in the network itself | care | +3 | Other people + `neutrality_auditor` | 3/month | Low |
| Flag abuse | — | 0 | Weight by historical quality and diversity; never automatic sanction | — | High: coordinated reports |
| Invite via QR | — | 0 | — | TC-2 quota | High: farms |
| Capture telegram or tally sheet | **outside** (TC-13) | 0 | Tally-sheet network | — | NG-13 |
| Evidence proven false or manipulated | reliability | −15 and quarantine | Registered investigation (TC-4) + appeal | — | — |
| Moderation reverted for abuse | reliability | −3 | Appeal panel | — | — |
| Confirmed malicious invitee | reliability | −5 and quota frozen | TC-3 | — | — |
| Rating as "useful" something later proven false | — | lowers weight as rater | Later verification [NV: *rater helpfulness*, Community Notes] | — | — |

**Never adds:** posts, reactions, followers, time online, votes cast or their
direction, agreeing with the majority, endorsements from one's own branch or from a coordinated group.

### Permissions by threshold (illustrative, to be calibrated)

| Permission | Requirement |
| --- | --- |
| Read, deliberate, upload evidence (with second verification) | Onboarding by invitation |
| Endorse (counts in consensus) | Verified person (DL-3) + 14 days. **Equal vote for all** |
| Invite | Reliability without sanctions + one dimension ≥ u1; the quota grows with level, cap 20/month (TC-2) |
| Verify others' evidence | Verification ≥ u2 or accuracy ≥ 90 % on control samples |
| Recover accounts | Level ≥ u3 + S5 controls of the trust-chain check |
| Open working forums | Two dimensions ≥ u3; forum limit; readable from level 1 (A11) |
| Enter the panel sortition | Verified person + 30 days, no active sanctions. **Low threshold**: avoids an elite |
| Moderate, appeal, hold keys | Sortition among eligible people (care ≥ u4, 90 days without sanctions), 6-month mandate, no immediate re-election, periodic confirmation (NG-10) |
| Mass onboarding at events | Role with mandate + co-signature of another reference person + cooldown (S3) |

### Bridging algorithm versus sensitive data (NG-5)

"Bridging" (a contribution counts if people who usually disagree rate it as useful) resists brigades from a
single group (02 §1, 04 §1), but the latent factor **infers political perspective**: indirect sensitive
data (art. 7 subsec. 3). Options: **(a) do not use it**: blind sortitioned panels and branch diversity
as the only measure of cross-cutting support (01 §5), low legal risk; **(b) ephemeral and restricted**:
computed only within each deliberation, not persisted per account, not exposed or labeled, used
only as a diversity constraint ("covers / does not cover") and published in aggregate (02 §2, 04 §1), with
a prior opinion from `electoral_counsel` and `data_protection_officer`, medium risk; **(c) persistent per
account**: ⛔ proposed. ★ **(a) now** (hackathon and phase 0); **(b) only after a favorable legal opinion**,
with an audit that it does not reward one pole.

## 3. Decisions and rule changes

| Layer | Content | How it is changed | Timelock |
| --- | --- | --- | --- |
| **Constitution** | Neutrality, consensus before action, privacy and minimization, non-partisan, no paid amplification, one person one vote, right of exit (open source and exportable data) | Supermajority ≥ 2/3 in **two votes** 30 days apart, high quorum, opinion from a sortitioned panel and from `electoral_counsel`. **Neutrality and "consensus before action" cannot be modified by vote** (03 G5) | 30 days |
| **Rules** | Consensus thresholds, interaction catalog, quotas, moderation, rubric | Qualified majority ≥ 60 % + quorum + `electoral_counsel` check | 7 days |
| **Parameters** | Points, caps, τ, panel sizes | A sortitioned technical panel proposes with a published simulation; the network ratifies or objects | 7 days |

- **Adaptive quorum (NG-19):** percentage of verified people active in the last 90
  days, with a published absolute floor. **No change applies to ongoing decisions** (04 §3).
- **Rule blackout (veda de reglas) (NG-9):** from 60 days before each election until the final count
  (escrutinio definitivo), rules and parameters are not changed, except for security with a public report. In addition, **operational
  freeze** from 48 h before until 3 h after the polls close (Electoral Code (Código Electoral) art. 71, via
  MARCO_LEGAL): no external actions, opinions, level changes, mass onboarding or account
  recovery; governance read-only (03 G8, S10).
- **Pause council (NG-14):** k of n custodians (proposal 5 of 9) of different origins (civil
  society, academia, journalism, technical experts), with no declared party ties, physical keys. **It can
  pause, never modify or execute.** Pause ≤ 14 days, public justification within 24 h, ratification
  by the network, review of each use. The `electoral_counsel` ⛔ works the same way: it stops, it does not decide.
  Complement: an ongoing sortitioned panel can suspend on suspicion of capture for a short period
  (04 §3). Custodians are usually public figures: their custody accounts must not have edges
  in the citizen graph (TC-15).
- **Mechanical cross-cutting consensus (RC-2):** an initiative moves to action when it gathers (i) a minimum of
  verified people and a percentage of agreement published beforehand; (ii) **branch diversity**:
  no branch contributes more than x % of the endorsements (S4 of the trust-chain check); (iii) no
  **reasoned objection without a recorded response**, including those from party accounts, which neither vote nor
  veto. It does not require classifying parties "by leaning" (01 §3). With NG-5 (b), perspective coverage is added.
- **Secret ballot with verifiable tally** (NG-17; 03 G4, G10): nothing published links votes with
  accounts; aggregates with a minimum threshold of k people.
- **Separation of powers and incompatibilities:** propose / admit / evaluate (panel) / decide
  (consensus) / execute (entity and author) / oversee (appeal, audit, `electoral_counsel`).
  Whoever moderates a case does not evaluate it on appeal; whoever proposes does not sit on the panel.

### Progressive decentralization (NG-8)

| Phase | Who can veto | Measurable criteria to move to the next |
| --- | --- | --- |
| **0 · Foundational** (today) | The author, on everything; publicly declared | Legal entity incorporated (V-4); regulations and constitution published; verifiable log operational |
| **1 · Transition** | Board of directors of the entity only for unlawfulness, reasoned and public; the author only over the constitution | N verified people (to be set); active custodians from ≥ 4 origins; registration of the database (art. 21, if applicable); external audit of the algorithm; adversarial simulations published |
| **2 · Autonomous** | No individual veto; only pause council and legal ⛔ | Federation with ≥ 2 operating organizations (01 option C, PP-2); after the 2027 elections |

A "DAO" that hides an owner is worse than a declared owner (01 §3).

## 4. Collegiate evaluations of modalities towards platforms

Purpose: decide whether a **modality** (open letter, access-to-information request, A2 audit,
A4 dashboard, regulatory proposal, new ones) is adopted, adjusted or discarded; then, whether each
**activation** proceeds; afterwards, whether it worked. The modality is evaluated once with a full panel; each
activation, with a reduced panel or a fast track with an approved template, always with steps 9 to 12.

### Process

1. **Proposal:** civic-deliberation template + action sheet: what is requested, from whom, evidence
   (A1–A4 with hash and methodology), **success metric and baseline defined beforehand**, deadline, reversal.
2. **Formal admission** (peer moderation, without evaluating the merits): complete; non-partisan; does not consist
   of mass reports or takedown requests for people's content; does not name individual users.
3. **Verifiable sortition:** list of eligible people published as a hash before the seed; public seed
   after the commitment (randomness beacon [NV: drand] or a number published afterwards, e.g.
   official lottery [NV]); fair sortition algorithm (Flanigan et al., *Nature* 2021; free tool
   [NV: Panelot]) with **non-political** strata: coarse region, seniority, reputation band, at most
   1–2 people per branch, gender if voluntarily declared. Never affinity. Nobody repeats a panel in
   the quarter. Size: NG-7. Anyone can rerun the sortition.
4. **Conflicts of interest:** private declaration of an employment or contractual relationship with the evaluated
   platform, a party or the proposer; the person recuses themselves without saying why; challenge. Party
   membership is not asked.
5. **File and statement of defense:** evidence, metrics, arguments for and against; **prior right of
   reply** for the platform with a deadline (03 §4.3); written statement from each party that wishes, with
   identical format and length; experts and `electoral_counsel` with voice and no vote.
6. **Asynchronous deliberation** of 1 to 2 weeks, short materials, no unrecorded private channels.
7. **Individual, secret score per criterion**, with written reasoning, according to the rubric.
8. **Public opinion:** adopt / adopt with changes / reject; aggregated scores; **reasoned
   dissents**, signed with a pseudonym (signing with a name requires a public profile and accepting the risk for
   the subnetwork, TC-15); sources; finding language ("we observed X in N cases with methodology Y"),
   never accusatory; who voted what is not published (art. 7).
9. **Ratification by the network** through cross-cutting consensus (§3); if it contradicts the opinion, the reason is recorded.
10. **`electoral_counsel` check**: a ⛔ stops it until the author decides.
11. **Author's decision** while phase 0 lasts; in phases 1–2, **signature of the legal entity** (03
    §4.6). Execution **outside the blackout** (§3); opinions about advertising during the blackout are published afterwards.
12. **Subsequent measurement:** predefined platform-accountability metrics (time to visible
    action, % without a label at 24/48/72 h, ads missing from the ad library, ads during the blackout), with
    baseline and comparison group; formal responses received; documented policy
    changes. Without a baseline no effect is claimed. A new panel publishes the review and adjusts the rubric.

### Public rubric (0–3 per criterion, written reasoning)

| Criterion | Question | Minimum | Eliminatory |
| --- | --- | --- | --- |
| Evidence | Verified, independent captures, with hash and chain of custody? Does it separate what was extracted from what was confirmed? | 2 | Yes |
| Legality | Is there a `electoral_counsel` ⛔? Does it respect the blackout (veda) and Law 25.326? | No ⛔ | Yes |
| **Mirror test (symmetry)** | Would it be applied the same way if the content favored another force? Rewrite the case swapping actors and document symmetric cases | 3 | Yes |
| No reports or silencing | Does it ask for transparency or compliance, not for deleting people? Does it avoid report buttons and mass reports? | 3 | Yes |
| Object | Does it evaluate platform conduct (advertising, algorithms, commitments), not people's? | 3 | Yes |
| Proportionality | Is it the least burdensome action that achieves the goal? | 2 | No |
| Reversibility | Can it be withdrawn or corrected? Does it have an expiry? | 2 | No |
| Risk for participants | Persecution, exposure, SLAPP (participant-protection) | 2 | No |
| Measurability | Metric, baseline and deadline defined beforehand? | 2 | No |
| Cost and capacity | Is there someone to execute and measure it? | 1 | No |

**How to document without reporting:** passive observation and re-check of the public status (A1), ad
libraries (A2), exposure panel with consent (A3), public information requests (Law
27.275 (Ley 27.275)), right of access (Law 25.326, P-4). Third-party data in captures: blur, minimize, set retention.

## 5. Political parties

- **Generic role accounts** in separate subnetworks (TC-11 ★, TC-14 ★), without identifying people,
  outside the trust network; their poll watchers (fiscales) only in the tally-sheet network (TC-7).
- **No vote** in consensus or panels; **no veto**. They can argue, file statements and reasoned
  objections with an identical quota and format. A reasoned objection requires a recorded response; it does not stop things by itself.
- **Verifiable equality:** public permissions table identical per party and role type; identical cap
  of role accounts per party and territorial level; automated test that compares them.
- **Sanctions on roles (NG-12):** they fall on the role and on the party's root account, with an identical and
  public scale. The party, a legal entity, answers for what its roles publish and accepts this in terms
  of use that are the same for all (03 §3.1). Delegations with expiry, frozen on election day
  except for replacements.
- **Party activism in the citizen network:** legitimate and not detectable by membership. Never link networks to
  "discover" activists (art. 7 subsec. 3). Behavioral defense: branch diversity, synchrony, human review.
- **Blackout:** pause of institutional posts during the freeze window (§3).

## 6. Phases

**Hackathon (fictitious data; nothing is installed without the author's approval):** this SPEC with the NG-
decisions; draft constitution in three layers; reputation rules in versioned JSON and a **simulator**
(formula, catalog, caps, decay; adversarial scenarios G1–G4: capture by branch, slow Sybil,
purchase, rating ring); simple **append-only log** (signed hash chain in JSON)
verifiable with a script; demonstrative **verifiable sortition** and a **sample opinion** with the rubric
on a fictitious modality (open letter about ads during the blackout) with a simulated statement of defense; navigable
prototypes (review-pipeline): proposal → admission → panel → opinion → consensus → legal check →
execution frozen during the blackout; "why did my level go up or down" screen with appeal; permissions table per party.

**Later:** incorporation of the entity (author's procedure), registration of the database, external witnesses
of the log, federation, real cryptographic secret ballot, anonymous credentials (TC-8), bridging in
production if NG-5 (b) is approved, public profiles only after NG-20, calibration of thresholds with real
use (lesson from Decide Madrid, 02 §1), conviction voting for the backlog (NG-18), external audit
of the algorithm, evaluation of Decidim/CONSUL [NV].

## 7. Pending decisions (unified)

| ID | Decision | Origin | Options (★ recommended) |
| --- | --- | --- | --- |
| NG-1 | Form of the network | GV-1, GOV-1, NG-TS-4, 03 §5 | Verifiable off-chain within a legal entity, designed to federate ★ · on-chain DAO ⛔ · declared centralized |
| NG-2 | Responsible legal entity (refines V-4) | 03 §1.3 | Civil association (asociación civil) ★ · allied CSO that hosts it · foundation · foreign wrapper (not recommended) |
| NG-3 | Vote weight | GV-3, GOV-2 | One verified person, one vote ★ · weighted by reputation |
| NG-4 | Structure of reputation | GV-2, GOV-3, NG-TS-2, TC-2 | Continuous per dimension with decay and visible level 0–12 ★ · single score with many levels · 0–3 table |
| NG-5 | Bridging algorithm / latent factor | GOV-5, NG-TS-1, 01 §5 | (a) do not use, now ★ · (b) ephemeral and restricted after legal opinion, later ★ · (c) persistent ⛔ |
| NG-6 | Who evaluates modalities | GV-4, GOV-4 | Sortitioned panel + rubric + opinion + ratification ★ · fixed elected committee · high levels · team |
| NG-7 | Panel size | 01, 02, 04 | 15 for modalities, 9 for activations ★ · 15–25 · 9–15 |
| NG-8 | Progressive decentralization | GV-5, GOV-6 | Three phases with published criteria and dates ★ · immediate · no plan |
| NG-9 | Rule blackout and freeze | GV-6, 03 G8 | 60 days before until the final count + 48 h / 3 h freeze ★ · another period · no blackout |
| NG-10 | Sensitive roles (moderation, appeal, custody) | NG-TS-3, TC-2, 02 | Sortition among eligible people with 6-month mandate and confirmation ★ · peer election · appointment |
| NG-11 | Visible gamification | NG-TS-5 | No: no rankings, badges or streaks ★ · private badges · rankings |
| NG-12 | Sanction on party role accounts | NG-TS-6 | On the role and the root account, identical and public scale ★ · role only · no sanction |
| NG-13 | Tally-sheet captures as a source of reputation | NG-TS-7, TC-13 | Not in the hackathon; later only with anonymous credential ★ · link by account ⛔ |
| NG-14 | Emergency brake | 01 §3, 03 G6, 04 §3 | 5-of-9 council that only pauses + short pause by an ongoing panel ★ · council only · panels only |
| NG-15 | Verifiable log and anchoring | 01 option B, 03 §1.4 | Merkle log + external witnesses, daily hash on allies' and press sites ★ · also on a public chain (no data) · server only |
| NG-16 | Decay half-life | 01, 02, 04 | ~90 days with dignity floor, calibrated in simulation ★ · 6 months · no decay |
| NG-17 | Secret ballot in consensus | 03 G4, G10 | Encrypted with verifiable tally and aggregates of k people ★ · public vote · to be defined later |
| NG-18 | Advanced voting mechanisms | 01 §2 | Postpone; conviction only for the backlog in v2 ★ · quadratic · liquid |
| NG-19 | Quorum | 01 §3 | Adaptive (% of people active in 90 days) with absolute floor ★ · fixed |
| NG-20 | Identified public profiles and links with other networks in governance (TC-15) | Author's clarification | **Unresolved**; requires assessment by `electoral_counsel` and trust & safety. TC-15 options: separate public persona, with no edges or history, level only via anonymous credential · linked with hidden edges and explicit warning of the risk for the subnetwork · no public profiles for now. For public roles (custodians, spokespeople): accounts with no edges in the citizen graph |

## 8. Acceptance criteria

1. No external action occurs without an opinion from a sortitioned panel, recorded consensus, an
   `electoral_counsel` check and the author's decision (phase 0) or the entity's signature.
2. In every vote each verified person weighs exactly 1: an automated test compares the
   result with and without reputation and finds no difference.
3. The log is append-only and verifiable: an independent script reproduces the Merkle root and
   detects the alteration of any entry.
4. A panel's sortition is reproducible by a third party with the hashed list and the seed; in 100
   simulated sortitions no branch contributes more than 2 people.
5. Adversarial simulation: a branch of 50 coordinated accounts and a rating ring of 20 do not move
   any account more than one visible level nor exceed the cross-cutting threshold; less than 1 % of honest
   accounts affected (extends TC criterion 3).
6. No reputation signal uses opinion content, party or vote direction: review by
   `neutrality_auditor` of code and rules.
7. Every level downgrade has a readable reason and appeal; average resolution time and percentage
   reverted published in aggregate.
8. During the blackout and freeze no rule change, level change or external action is executed (simulated clock);
   the parties' permissions table is identical across parties (automated test).
9. Nothing public (opinions, aggregates, profiles) allows linking a trust account with a
    person or with their subnetwork without their explicit choice (TC-15); trust & safety review.
10. Checks by `electoral_counsel`, `data_protection_officer`, `neutrality_auditor` and
    `trust_safety_analyst` recorded before onboarding real people.

## 9. Risks

| Risk | Mitigation |
| --- | --- |
| Capture by a coordinated group or party (slow infiltration) | One vote per person; branch diversity; sortition; timelocks; rule blackout; right of exit |
| Reputation plutocracy and closed elite (Wikipedia, Stack Overflow) | Reputation without vote; decay; low threshold for panels; measure retention of newcomers |
| Goodhart and Sybil | Only signals validated by third parties; √ and caps; control samples; no rankings; in-person QR + graph (TC); extended S4; endorsements weighted by branch diversity |
| Sensitive data by inference (bridging, opinion groups, graph) | NG-5 (a) now; limited retention; aggregates; nothing linked to accounts in what is published |
| **Public profile that exposes its subnetwork** (TC-15): whoever invited them and whoever they invited are one step from a known person; cross-referencing with other networks | NG-20 unresolved; meanwhile, no public profiles or external links; public roles without edges; assessment by `electoral_counsel` and trust & safety |
| Personal liability of decision-makers (simple association, SLAPP) | Legal entity before real onboarding; finding language; prior reply; quick retraction |
| Paralysis: everything goes through a panel | Fast track for activations of approved modalities; asynchronous, short panels |
| Delegitimization ("the network belongs to party X") | Mirror test; public opinions and dissents; evidence symmetry metrics (04 §5) |
| Hostile fork presenting itself as "the network"; abuse or theft of pause keys | Entity signatures on official publications; trademark [NV]; k of n, physical keys, pause only, expiry and report within 24 h |

## 10. Questions for a lawyer and for security

1. Can the bylaws of a civil association delegate decisions to votes of non-member
   users, and with what liability for the board of directors?
2. Risk that the network is treated as a simple association (Civil and Commercial Code (CCyC) 187-192) before the entity exists? Obligation
   to register the database (art. 21) and with what declared purpose?
3. Does non-transferable reputation fall outside "virtual asset" (Law 25.246 (Ley 25.246) art. 4 bis)?
4. Are opinions about platforms covered by art. 110 of the Criminal Code (CP) (public interest), and what
   civil standard applies?
5. Does the ephemeral latent factor (NG-5 b) constitute a "file" under art. 7 subsec. 3? Does a data-processing
   mandate scheme (art. 25) with all parties compromise the non-partisan status (National Electoral Chamber
   Ruling (Acordada CNE) 128/11 [NV])?
6. Public profiles (NG-20): is the network liable for the re-identification of the subnetwork of whoever opts for a
   public profile? What informed consent is enough? How to verify a link with another network without
   the external platform being able to cross-reference it with the trust account?
7. Security: audited threshold scheme for the pause council; secret ballot with verifiable tally
   without a trusted coordinator; branch diversity without opening the graph (A5-b); anonymous credential
   "level ≥ N" without linkability (TC-8).

## Sources

Those of each position, with their marks. Verified there: Flanigan et al., *Nature* 596 (2021); Wojcik et
al. (2022); Beanstalk (2022); concentration in token DAOs; vTaiwan; Decide Madrid; Citizens' Assembly
of Ireland; Law 25.326 and Electoral Code on Infoleg (03). **Not verified [NV]:** *CFTC v. Ooki DAO*;
RFC 9162 and Sigsum; drand; Panelot; Community Notes algorithm and *rater helpfulness*; Ostrom (1990);
Stack Overflow and Decidim; exact texts of the CCyC, Law 26.215 (Ley 26.215) art. 15 and Acordada CNE 128/11; trademark registration.
