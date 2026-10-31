> Automatic English translation of [`sdd/specs/trust-chain-identity/SPEC.md`](../../../../../sdd/specs/trust-chain-identity/SPEC.md)
> at commit `e314f0f`. The Spanish original prevails.

# SPEC · Identity without personal data: trust chains via QR

Status: **author's proposal (31/10/2026) drafted for his review; TC-n decisions
pending; `electoral_counsel` check (legal and cybersecurity) pending.**
Responds to RC-5 of [civic-network](../../../../../sdd/specs/civic-network/SPEC.md) and PP-3 of
[participant-protection](../../../../../sdd/specs/participant-protection/SPEC.md), and refines RC-3 (parties).
Affects the authentication of [scrutiny-backend](../scrutiny-backend/SPEC.md) and
[fiscal-planning](../fiscal-planning/SPEC.md).

## The author's idea

- People join **without giving personal information**: someone who is already inside
  invites them in person with a **QR**. We do not know identities, but we do know who invited whom.
- If a malicious agent appears, **the subnetwork that invited them** is investigated.
- There is a **hierarchy**: the most committed and active people can invite more
  people than others.
- **Political parties** do register, with **identified officers**, and
  have special characteristics.

## Accounts for people

1. **QR onboarding, in person.** The inviter's app generates a single-use QR,
   signed with their device key and short-lived (for example, 2 minutes).
   The invited person scans it, their phone generates its own key pair and they choose
   a pseudonym. The server stores the public key, the pseudonym and the edge
   `invited → invitee` with the date. It **does not store** name, national ID (DNI), phone number, email or location.
2. **Session:** the device signs each request with its key (kept in the Secure
   Enclave or Keystore). It is the same basis as the `deviceToken` of scrutiny-backend.
3. **Recovery** (lost phone): social recovery. The inviter and
   another person of sufficient level confirm a new key in person. The old account
   is revoked.

## Invitation levels and quotas

Levels depend on **behavior in the network**, never on party, ideology or the
content of opinions. The values are proposals to be calibrated (TC-2).

| Level | How it is reached | Can | Invitation quota |
| --- | --- | --- | --- |
| 0 · New | By invitation | Read, deliberate, upload captures (they require a second verification) | 0 |
| 1 · Active | 14 days and contributions confirmed by other people (for example, 3 matching captures or 5 valued contributions) | The above and endorse proposals | 2 per month |
| 2 · Committed | 60 days at level 1, sustained contributions and no sanctions | The above, verify others' captures and recover accounts | 5 per month |
| 3 · Reference person (referente) | Chosen by peers of level 2 or higher, with a renewable mandate | The above, organize mass onboarding events with a special quota, moderate | 20 per month or per event |

- The quota **renews** over time. What is not used does not accumulate without limit.
- **Upward accountability:** if someone invited turns out to be malicious, the
  inviter temporarily loses quota and their level goes under review. This way people take care
  of whom they invite, without being punished in advance.

## Detection and investigation of malicious agents

- **Signals:** captures that systematically diverge from those of other people at
  the same polling table (mesa); anomalous volume; many new accounts from the same branch acting
  in coordination; peer reports.
- **Graph analysis:** attackers usually create many fake accounts that
  connect little with the honest network (Sybil attack). Trust-graph ranking methods
  exploit that pattern. They are applied to the invitation structure, not
  to content.
- **Proportional containment, not mass expulsion:**
  1. Quarantine of the flagged account: its contributions stop counting for consensus and
     aggregates.
  2. The quotas of its branch are frozen (whoever invited it and whoever it invited).
  3. The subnetwork is investigated with an audit log. Affected people can
     appeal.
  4. Only with evidence: revocation of the involved accounts and recalculation of
     what they contributed. What was extracted and what was confirmed are recalculated separately.
- No measure is based on expressed political opinions.

## Principle: the app does not register people (author's clarification, 31/10/2026)

- **By default, nobody is registered as a person.** The account is a key and a
  pseudonym, with no data identifying anyone.
- **Public profile, only by choice:** whoever wants public visibility can
  activate a profile with their name, their photo or links to their accounts on other networks.
- **Risk to assess in depth:** an identified public profile **exposes its
  subnetwork**. Whoever invited them and whoever they invited are one step from a known person.
  If the edges leak or are inferred from behavior, they can be re-identified.
  It also exposes their previous pseudonymous history, if linked.
- **Alternatives to weigh (TC-15):**
  1. **Public profile as a separate persona** ★: a new key, with no edges or
     history linked to the trust account. Reputation can be shown only
     with an anonymous credential ("level ≥ N"), without revealing the account.
  2. Public profile linked to the account, but with the edges hidden and an explicit
     warning about the risk for their subnetwork.
  3. No public profiles at this stage.
- **Linking accounts from other networks** (X, Instagram, TikTok…) adds another risk:
  those platforms can cross-reference the data. It requires a verification that does not publish
  the link between the external account and the trust account.
- Pending: assessment by `electoral_counsel` (legal and security) and by trust & safety
  before deciding.

## Two disconnected networks (author's clarification, 31/10/2026)

- **Trust network:** pseudonymous identity, invitations, reputation, deliberation
  and governance. It is the one described in the previous sections.
- **Tally-sheet publication network:** onboarding of devices to capture telegrams and
  tally sheets (actas), submission, cross-checking and notices ([scrutiny-backend](../scrutiny-backend/SPEC.md),
  [fiscal-planning](../fiscal-planning/SPEC.md)).
- **They can be disconnected from each other.** A capture device does not need an
  account in the trust network, and from one network it is not possible to know who is who in
  the other: separate keys, identifiers and databases. The quality of a capture is
  validated by matching other captures and the official count (escrutinio oficial), not by the
  reputation of the uploader.
- If later on it were wanted that confirmed captures add reputation, it would be done
  with an anonymous credential ("I contributed N matching captures") that does not link the
  accounts (TC-8, TC-13).

## Political parties

**Party subnetworks with special rules** (author's clarification, 31/10/2026):

- **They do not identify people. They identify key roles generically**, for example
  "national legal representative (apoderado/a nacional)", "poll watcher coordination for section X" or
  "general poll watcher (fiscal general) of circuit Y". Each role is a **role account** with its own key.
  Different people can hold it over time (key handover or
  delegation with expiry), and who holds it at each moment stays **within the
  party**.
- Polling-table poll watchers (fiscales de mesa) are onboarded in the **tally-sheet publication network** with the
  institutional QR of a role account. No personal label: the server knows that the
  device was enabled by a role of a party, not who the person is.
- **Institutional registration of the party:** the party's root account is verified once
  against the electoral court registry (to be verified with
  `electoral_counsel`). The data of whoever carries out that procedure are handled with their
  consent, outside Git, with restricted access and without being associated with the
  role accounts.
- **Same characteristics for all parties** (neutrality):
  - institutional account labeled as such, separate from people's accounts;
  - publication of official positions in deliberation spaces, with the
    same rules and limits;
  - **onboarding of their poll watchers** in the tally-sheet publication network, with the QR of a
    role account. They stay outside the trust network: they add no quotas or citizen
    levels, so that a party cannot capture the network;
  - assignment of polling tables to their poll watchers (integrates with
    [fiscal-planning](../fiscal-planning/SPEC.md));
  - the same view of captures and cross-checks as any person. No access to the
    identity or the graph of people.
- Network actions still require consensus. A party does not have more votes
  for being a party.

## Personal data and risks

- **The invitation graph is sensitive.** In a political context it can reveal affinity
  networks. Political opinions are sensitive data (Law 25.326 (Ley 25.326), arts. 2 and 7, to be
  verified). Proposal: store the edges encrypted, with access only for
  registered investigations and with limited retention (TC-5).
- Nothing of the graph is published. Public statistics are aggregated.
- Risk of **coercion** (someone forced to invite or to hand over their phone): low
  quotas, fast revocation and social recovery.
- Risk of **exclusion**: whoever knows nobody inside cannot get in. Mitigated
  with mass onboarding events by reference people and allied organizations (PP-3).

## Graph privacy: framework and proposal (research of 31/10/2026)

**Legal framework (to be verified with `electoral_counsel` and a lawyer):**

- Law 25.326 defines political opinions as sensitive data (art. 2). Nobody
  is obliged to provide them, and it is **prohibited to build files that reveal them directly
  or indirectly** (art. 7 subsec. 3).
- Political parties may keep a registry of their members (art. 7). Legal
  doctrine treats party membership (afiliación) as sensitive data, and case law on its
  publicity is not uniform.
- A pseudonym is not enough for data to stop being personal if it can be
  re-identified (for example, by crossing the graph with the device).

**Design consequence:** the graph of a citizen, non-partisan network should not
reveal affinities. The risk appears when **mixing it with party nodes** or with
the positions expressed in the deliberation. Applicable good practices:
minimization, separation of duties, encryption with quorum access, limited
retention, aggregated-only statistics and credentials that prove an attribute without
revealing who the person is.

**Proposal:**

1. **Two separate graphs.**
   - **Citizen:** without party labels.
   - **Per party:** its officers and poll watchers identified as such. Each
     party is responsible for its data (art. 7 exception) and the network processes them
     on behalf of the party. **There are no edges between the two graphs.** A party
     invitation never grants a citizen level.
2. **Encrypted edges with quorum opening.** The server stores each edge
   `invited → invitee` encrypted. Opening it requires a quorum (for example, 3 of
   5) of custodians from the elected moderation (RC-4), each of a different origin.
   Every opening is logged and reported in aggregate form. For quotas,
   counters suffice: there is no need to read the graph.
3. **Receipt on the phone.** Each device keeps the signed receipt of
   its own invitation, and can prove its branch if investigated.
4. **Retention:** edges are deleted after a period following the election
   (TC-5). Public statistics are aggregated, with noise if groups are small.
5. **Later on: anonymous credentials** (TC-8). The person proves "I have level ≥ 2"
   or "I am a verified person" without revealing their account. There are IETF draft
   standards that combine Privacy Pass with BBS signatures.
6. **Reference:** BrightID uses a social graph with trusted seeds and a variant
   of SybilRank, without personal data. Its own academic review acknowledges limits
   against combined attacks. It should be measured with simulations (criterion 3) before
   relying on it.

## Several users per phone

In households that share a phone, limiting to one person per device excludes
people. Allowing many accounts makes fake-account farms easier. Proposal to
weigh (TC-9):

- **By default, one citizen account per device.** With the "shared phone"
  flag, **up to 3 profiles** are allowed, each with its own key and its own
  in-person invitation from a **different** person. The device's invitation quota
  is shared.
- The server does not store the device identifier. It stores a salted hash
  **per function**, which allows counting profiles without linking a citizen profile with
  a party poll watcher one.
- A person can be a citizen and a party poll watcher on the same phone, but
  in **unlinkable profiles**, so that their citizen profile does not reveal their affiliation.
- Device attestation (App Attest / Play Integrity) helps against
  emulators. It is not infallible and must not be used as an identifier.

## Reputation and internal forums

- **Name:** it is proposed **not** to call it "social credits", because of the association with
  state-controlled citizen scoring systems. "Participation reputation" or
  "quotas" is proposed (TC-10).
- Besides inviting, reputation enables **internal working forums**. People
  of level 2 or higher can open groups where proposals are developed before
  moving to public deliberation
  ([civic-deliberation](../../../../../sdd/specs/civic-deliberation/SPEC.md)). Every proposal that asks for
  action goes through the public phase and the consensus of the whole network.
- **Risks:** that an elite forms, that the network becomes opaque, or that a coordinated
  group captures it. Mitigations:
  - forums can be read from level 1;
  - public reputation criteria computed only from behavior;
  - term-limited mandates for reference people;
  - limit of forums per person;
  - reputation cannot be transferred or bought.

## Pending decisions

| ID | Decision | Options |
| --- | --- | --- |
| TC-1 | Onboarding method | In-person QR ★ · remote QR too (link) with a lower quota · both with distinct labels |
| TC-2 | Levels and quotas | Table above as a starting point ★ · fewer levels (0/1/2) · fixed quotas without levels |
| TC-3 | Upward accountability | Temporary loss of quota ★ · no consequences · level downgrade |
| TC-4 | Who investigates a subnetwork | Elected moderation team (RC-4) ★ · network operator · mixed committee with parties |
| TC-5 | Graph storage | Encrypted with logged access and limited retention ★ · plaintext with access control · only on devices (makes investigation harder) |
| TC-6 | Parties: verification of officers | Against the electoral court registry ★ · sworn statement · both |
| TC-7 | Party poll watchers in the hierarchy | Outside the citizen hierarchy ★ · inside, at level 0 · poll watcher's choice |
| TC-8 | Anonymous credentials (proof that someone is a person without linking them to their account) | After the hackathon ★ · now |
| TC-9 | Users per phone | 1 by default, up to 3 with "shared phone" ★ · always 1 · unlimited with attestation |
| TC-10 | Name and scope of reputation | "Participation reputation", enables invitations and forums ★ · invitation quotas only · another name |
| TC-11 | Party graphs | Subnetworks with generic role accounts, separate from the citizen graph and with no cross edges ★ (author's clarification) · party label inside the citizen graph |
| TC-13 | Relationship between the trust network and the tally-sheet publication network | Disconnected ★ (author's clarification) · linked with anonymous credential · linked by account |
| TC-15 | Identified public profiles | Separate public persona, with no link to the trust account ★ · linked with hidden edges and warning · no public profiles for now |
| TC-14 | Handover of party role accounts | Delegation with expiry signed by the superior role ★ · key handover · one account per person within the role |
| TC-12 | Opening of edges | Quorum of custodians of different origin ★ · network operator with logging · never (only receipts on the phone) |

## Acceptance criteria

1. A QR onboarding completes in less than 1 minute between two phones, without asking for any
   personal data.
2. A used, expired or signature-tampered QR is rejected (contract vectors).
3. With a simulated branch of 50 fake accounts invited from a single account, the
   graph analysis flags them and containment leaves them out of the aggregates without
   affecting more than 1 % of honest accounts (to be measured in simulation).
4. Quotas and levels are computed only from behavioral signals: verified by a
   neutrality review.
5. Parties have exactly the same functions as each other.

## electoral_counsel check (legal and cybersecurity): pending

To assess: sensitive data and social graph (Law 25.326); verification and data of
party officers; labeling of party poll watchers; threat model (Sybil,
device theft, coercion, quota abuse, compromise of a level 3 account,
attack on the server on election day); applicable NIST SP 800-63 and OWASP MASVS
controls.

## Adjustments from the electoral_counsel check (31/10/2026)

Report: [checks/electoral_counsel.md](../../../../../sdd/specs/trust-chain-identity/checks/electoral_counsel.md). The non-blocking
mitigations are incorporated as requirements. The ⛔ items are left to the author.

- **QR with a two-step exchange** (S1): the inviter's QR is not enough on its
  own. The invited phone replies with its own QR or short code, and the inviter
  scans or confirms it. That way a forwarded photo of the QR cannot be used to onboard people
  remotely.
- **Social recovery** (account hijacking risk): requires two in-person confirmations
  from accounts in different branches, a 72 h wait with a notice to the
  previous device, and it is not allowed during the electoral blackout.
- **Unlinkable profiles:** the per-role hash is derived from a secret generated
  on the phone, different for each role and never from a stable device
  identifier.
- **Fake account detection and opening by quorum:** still open (L2 ⛔ for
  real data). TC-5 and TC-12 must be decided, and a detection method chosen that does not
  read the graph in the clear.
- **Party role accounts** (author's clarification): with TC-11 ★ and a per-party
  engagement contract, L1 goes down to ⚠️.
