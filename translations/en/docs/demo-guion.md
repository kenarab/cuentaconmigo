> Automatic English translation of [`docs/demo-guion.md`](../../../docs/demo-guion.md)
> at commit `13f081b`. The Spanish original prevails.

# Demo script · delivery 31/10/2026, 17:45

Coordinator's draft for the author to adjust. Duration: about 5 minutes.
Assumes the decision recommended in #1: vote count + AMBA simulation, and the network as vision.

## 1. The problem (30 s)

Millions of us discuss politics on social networks with someone else's rules. CuentaConmigo is a
citizen, non-partisan network to protect the rules of the game in 2027. All parties
participate on equal terms, and nothing is done without a registered consensus
([vision](../../../sdd/specs/vision/SPEC.md)).

## 2. Closing the process: the vote-count app (2 min, live iPhone)

1. "New capture" → Single Ballot (Boleta Única) warning.
2. "Use a sample telegram": a real official telegram (Andy's samples). The polling table
   fills in by itself.
3. Show the drop-down lists: district → section → polling place with search
   → polling table. **User experience is fundamental:** you choose, you don't type.
4. Enter two or three values by tapping the numbers detected by the OCR. Force a
   sum-mismatch warning and show the validation.
5. Confirm: the capture is locked with a SHA-256 hash and date (chain of custody).
   Export the package.

## 3. Why every entry counts: the AMBA simulation (1 min, browser)

`python3 -m http.server` at the repo root and open `design/prototypes/simulacion-amba/`.

1. Real per-polling-table data from the 2023 general election: 29,962 polling tables, CABA + 24 partidos.
2. Replay with **high arrival bias**: the naive sum deviates 3–4 points and the
   stratified one stays within half a point with 5 % of the polling tables.
3. Permanent banner: simulation of a finished election. The electoral blackout of art. 71 inc. h
   forbids publishing projections during an ongoing election.

## 4. What comes next: the network (1 min, slide or SPECs)

- Identity without personal data: in-person QR onboarding and chains of trust
  ([trust-chain-identity](../sdd/specs/trust-chain-identity/SPEC.md)).
- Decentralized governance without a token. Reputation grants tasks, not votes.
  Actions against platforms go through a collegiate evaluation with a panel
  drawn by lot and a public rubric ([network-governance](../sdd/specs/network-governance/SPEC.md)).
- Backend with server-side OCR and its own quick count, ahead of the official one and
  respecting the electoral blackout ([scrutiny-backend](../sdd/specs/scrutiny-backend/SPEC.md)).
- Planning mode for party poll watchers of small parties
  ([fiscal-planning](../sdd/specs/fiscal-planning/SPEC.md)).

## 5. Closing (30 s)

We are looking for devs, data, design, law, journalism and communication. Open repository:
github.com/kenarab/cuentaconmigo.

## Checklist before presenting

- [ ] App reinstalled on the Mac with `git pull && ios/scripts/install-device.sh` (brings
      the drop-down lists and the samples).
- [ ] Simulation open in the browser with the local server.
- [ ] Phone with the screen mirrored on the projector.
- [ ] Do not show images of real telegrams with people's data on the big screen
      without covering them (legal check).
