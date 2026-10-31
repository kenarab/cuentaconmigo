> Automatic English translation of [`data/establecimientos/README.md`](../../../../data/establecimientos/README.md)
> at commit `6b8eeec`. The Spanish original prevails.

# Roster of polling places (establecimientos de votación)

`nomina-2025.json`: district → section → polling place (code, name, address,
locality) → polling tables as ranges `[from, to, circuit]`, from the 2025 legislative election.
It is used by the drop-down lists to identify the polling table
([telegram-capture](../../sdd/specs/telegram-capture/SPEC.md), F-16).

- Source: Ministry of the Interior, open data, `elecciones_legislativas_2025.zip`
  (`localesDeVotacionyMesas.csv`; circuit taken from `resultados2025.csv`). URL and
  SHA-256 inside the JSON. The original download stays in `data/private/` because of its size.
- Regenerate: `scripts/establecimientos/build_nomina.py`.
- 24 districts, 17,292 polling places. **No coordinates** in the source: the
  location-based suggestion (F-15) needs to geocode the addresses.
- The 2027 roster will be published close to the election; until then, 2025 is the
  closest reference. Public data, no personal information.
