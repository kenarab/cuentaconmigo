> Automatic English translation of [`sdd/specs/funding-and-ai-factcheck/SPEC.md`](../../../../../sdd/specs/funding-and-ai-factcheck/SPEC.md)
> at commit `2a7df5e`. The Spanish original prevails.

# SPEC · Funding and AI-based verification of disinformation

Status: **desk research; options for the author, nothing decided.** Commissioned by the author and relayed by the Nexo session (2/11/2026), raised by voice as an idea. No one has been contacted. The author writes to Fundar on his own; this document neither replaces nor prepares that. Related to [vision](../../../../../sdd/specs/vision/SPEC.md) (axis B),
[platform-accountability](../../../../../sdd/specs/platform-accountability/SPEC.md),
[network-governance](../../../../../sdd/specs/network-governance/SPEC.md),
[participant-protection](../../../../../sdd/specs/participant-protection/SPEC.md) (PP-5, still open) and
[app-screens](../../../../../sdd/specs/app-screens/SPEC.md) (note with sources).

## 1. Request

1. **Funding:** who could fund a project like this, with sources.
2. **Tool:** AI that verifies from the outside, not under the control of the platforms, the falsehoods that circulate. According to the author, there are many that are easy to refute, and manipulation has become normalized across the entire political spectrum. It is not only a technical matter, and it costs money.

## 2. Fit with the product

The tool is axis B (Disinformation: detection, verification and community response), which the vision already names (`misinformation-response`, no SPEC yet), and the note with sources in app-screens. **Proposal:** treat it as the SPEC for axis B and not as a separate product. This way it inherits the rules in force:
- refute with sources, without seeking to silence people;
- do not use the platforms' reporting mechanisms;
- a registered consensus before any external action;
- the same metrics for all actors.

## 3. Tool: what exists and what can be done

| Component | State of the art (source) | Proposed use |
| --- | --- | --- |
| Detection of verifiable claims | Full Fact AI: F1 0.83 in detection; more than 40 fact-checkers in 30 countries and 12 national elections in 2024 ([Full Fact](https://fullfact.org/ai/), [arXiv 1809.08193](https://arxiv.org/pdf/1809.08193)) | Prioritize what to review, do not decide |
| Matching against already-published fact-checks | LLMs match humans in *claim matching* ([arXiv 2310.09223](https://arxiv.org/pdf/2310.09223v1.pdf)); 4-stage architecture similar to ClaimBuster ([survey](https://arxiv.org/pdf/2109.11427)) | Immediate response with an existing fact-check and its source |
| Verification in Argentina | Chequeado has Chequeabot and an AI lab; according to Africa Check, half of its weekly fact-checks start from claims detected by AI ([Chequeado](https://chequeado.com/que-hicimos-frente-a-la-desinformacion-en-2024-y-como-podes-ayudarnos-este-ano-electoral/), [Africa Check](https://africacheck.org/fact-checks/blog/how-were-using-artificial-intelligence-scale-global-fact-checking)) | Natural ally (PP-5 d); do not duplicate what they already do |
| AI-written notes rated by people | X opened the API for AI-written notes (7/2025), but only people rate them ([arXiv 2506.24118](https://arxiv.org/html/2506.24118v1)). In the field, LLM-written notes proved more helpful than human ones with equal exposure, in a single study of 1,614 notes ([arXiv 2604.02592](https://arxiv.org/abs/2604.02592)). After a note, reposts fall 45.7% (Slaughter et al., 2025) | Model to follow: the AI drafts, the network with diverse positions rates, a person publishes |

**Design proposal (to be validated):**
- The AI never issues an automatic public verdict. It detects, searches for sources and drafts a text.
- The network rates the draft against the criterion of "useful for people who usually disagree". Publishing requires human confirmation and linked sources.
- Start with the category the author marks as easy: verifiable data with an official source (dates, public figures, electoral rules).
- Measure equally across the whole spectrum: the sampling of what gets verified is auditable and published.
- Under the own-infrastructure rule, models run locally or on our own servers. Using a third-party LLM is a separate decision for the author to make.

**Costs that are not technical:**
- human moderation and rating;
- legal review of each public format;
- editorial work;
- computing.

Without funding, the realistic scale is a limited pilot.

## 4. Funding: who could

| Source | What it funds (source) | Fit | Risk |
| --- | --- | --- | --- |
| **IFCN Global Fact Check Fund** (Google and YouTube via Poynter) | Up to USD 12 M in total and USD 100 k per project; in 2026, unrestricted funds for sustainability (SUSTAIN). SUSTAIN 2027 is announced ([Poynter](https://www.poynter.org/ifcn/grants-ifcn/globalfactcheckfund/), [2026](https://www.poynter.org/ifcn/2026/ifcn-awards-750000-to-25-fact-checkers-navigating-a-funding-crisis/)) | Requires being an IFCN signatory or a partner of one; realistic route: alliance with Chequeado | Platform money that axis A measures: conflict of interest to be disclosed |
| **Luminate** (Omidyar) | Argentina Elections Project: funded Chequeado, Democracia en Red and Conocimiento Abierto; typical grants of USD 125–265 k; strategy 2022–2027 ([Luminate](https://luminategroup.com/posts/story/driving-civic-engagement-in-argentina-through-advocacy-fact-checking-and-technology), [strategy](https://luminategroup.com/storage/1653/Luminate-Strategy-2022-2027.pdf)) | Very high (technology and democracy) | Foreign; confirm validity after 2027 |
| **Luminate + Open Society + Fundación Avina fund** | USD 3 M for digital rights and democracy in Latin America, coordinated by Avina ([Forbes MX](https://www.forbes.com.mx/grupos-de-derechos-digitales-humanos-y-democraticos-recibiran-apoyo-de-3-mdd-en-al/), [Inside Philanthropy](https://www.insidephilanthropy.com/home/2020/8/19/with-osf-and-omidyar-backing-a-new-fund-targets-civic-engagement-in-latin-america)) | High | 2020 edition; confirm whether still active |
| **NED** | List of grants for Latin America, fiscal year 2024 ([NED](https://ned.org/wp-content/uploads/2025/04/LAC-Grant-Listing-FY24.pdf)) | Medium | Funds from the US Congress: risk of being perceived as foreign interference |
| **US Embassy / EU** | Calls for digital government solutions that CONICET compiled in 2026 ([CONICET](https://noasur.conicet.gov.ar/wp-content/uploads/sites/101/2026/03/Coleccion-de-Convocatorias-Febrero-2026_3.pdf)) | Low to medium | Foreign governments: the most sensitive (§5) |
| **Local public funds** | FITBA of the Province of Buenos Aires, $3,500 M in 2026, for companies, cooperatives and municipalities ([Espacio Tech](https://www.espaciotech.net/2026/08/10/buenos-aires-destinara-3-500-millones-a-financiar-nuevos-proyectos-de-tecnologia-e-innovacion)) | Low: not civic technology | Money from a government competing in the election: compromises neutrality |
| **Citizen donations** | Chequeado is partly sustained this way and publishes an annual funding report ([Chequeado](https://chequeado.com/que-hicimos-frente-a-la-desinformacion-en-2024-y-como-podes-ayudarnos-este-ano-electoral/)) | High in legitimacy, low in amount | Requires a legal entity and transparency |

Not verified:
- the 2027 amounts and deadlines of each source;
- whether NED and the US Embassy still maintain programs for Argentina;
- who funds Fundar (not researched: the contact belongs to the author).

## 5. Legal framework (preliminary check by `electoral_counsel`, self-check)

- **Law 26.215, art. 15, subsections e) and f):** prohibits parties and campaigns (art. 44) from receiving contributions from foreign governments or public entities, and from foreign natural or legal persons without residence in the country. Art. 66 also fines whoever donates ([InfoLEG](https://servicios.infoleg.gob.ar/infolegInternet/anexos/120000-124999/124231/texact.htm)).
  This does **not prohibit** a non-partisan civil association from receiving foreign funds. But
  ⚠️ if the network were to support a party or candidate, that support could be read as an in-kind contribution with prohibited funds.
- ⚠️ **"Political initiative" versus "non-partisan network":** the author described it as part of a political initiative, and AGENTS.md requires neutrality and consensus before acting.
  Recommendation: the tool verifies claims, not actors, under the same rules for the entire spectrum, and no funder may steer what gets verified. A political initiative of the author may *use* the public results like anyone else, but may not steer the tool.
- ⚠️ **Automatic verdicts:** an AI labeling something as false without human review exposes to claims for damage to honor and for errors; during the electoral blackout, to reproaches for influencing the campaign. In addition, Congress has bills that prohibit deceptive electoral content generated with AI (3728-D-2025) and that create an AI sandbox (3330-D-2026), which are not yet law
  ([HCDN](https://www4.hcdn.gob.ar/dependencias/dsecretaria/Periodo2025/PDF2025/TP2025/3728-D-2025.pdf),
  [Digital Policy Alert](https://digitalpolicyalert.org/event/43704-testing-requirement-in-legal-regime-for-the-responsible-use-of-artificial-intelligence-3330-d-2026-was-introduced-to-chamber-of-deputies)).
  Recommendation: always a responsible person and linked sources, as in §3.
- ⚠️ **Funds from platforms or from competing governments:** not illegal, but they affect perceived neutrality. Recommendation:
  - publish all funders and amounts;
  - set a cap per funder;
  - do not accept money from parties, candidates, sitting governments that are competing, or platforms audited by axis A, unless the author decides otherwise.
- **Personal data (Law 25.326):** analyzing posts by identifiable people requires minimizing data and not building user profiles.
- This check does not replace a human electoral lawyer: consultation is required before receiving any funds.

## 6. Questions for the author

1. **FV-1** · Is AI-based verification the SPEC for axis B (★) or a separate product?
2. **FV-2** · What level of autonomy does the AI have?
   - a) drafts rated by the network and published by a person ★;
   - b) automatic replies only when an existing fact-check exists;
   - c) automatic verdict (not recommended).
3. **FV-3** · What funding policy?
   - a) full transparency, a cap per funder and the exclusions of §5 ★;
   - b) only citizen donations and local foundations;
   - c) no own restrictions beyond the law.
4. **FV-4** · Through what vehicle to receive funds?
   - a) an own civil association;
   - b) through an allied organization (for example, an alliance with an IFCN signatory) ★;
   - c) decided after talking with Fundar.
5. **FV-5** · How is the tension between the author's "political initiative" and the non-partisan network resolved (§5)?
6. PP-5 remains open. The research suggests adding Chequeado (option d) as a technical partner of the tool, but that is for the author to decide.
