> Automatic English translation of [`data/ocr-samples/README.md`](../../../../data/ocr-samples/README.md)
> at commit `8dec901`. The Spanish original prevails.

# Telegram values for measuring OCR

Transcription of 15 official provisional-count telegrams (2015 runoff and 2017 PASO
primaries), to compare against the OCR in [telegram-capture](../../../../sdd/specs/telegram-capture/SPEC.md).

**The PDFs are not in this repository** because they include names, signatures and ID
numbers (see [AGENTS.md](../../../../AGENTS.md)). `manifest.json` states where to get each
one and its SHA-256. They are stored locally in `data/private/ocr-samples/`, outside Git.

## Files

- `planilla-valores.csv`: one row per cell (`;` separator).
- `planilla-cotejo.csv`: sum of each column against the written totals.
- `manifest.json`: original URL, Internet Archive copy, date and SHA-256 of each PDF.

## Status: draft, not confirmed by a person

Claude made the transcription by looking at the images (`origen = borrador_ia`). It is one
more automatic reading, not ground truth, until a person confirms it in `valor_confirmado`
and `confirmado_por`. To measure an OCR, use confirmed cells only.

## Columns in `planilla-valores.csv`

- `como_figura`: what is written on paper. `-` dash, `x` cross, `_` empty, `?` illegible.
- `valor`: the numeric interpretation. Dash and cross count as 0; empty and illegible have no value.
- `confianza`: the transcriber's self-assessment, not a measurement.
- `referencia_2015`, `cruce_2015`: check against the community database
  [Zequez/telegramas-balotaje-argentina-2015](https://github.com/Zequez/telegramas-balotaje-argentina-2015),
  which is not an official source either.

Cells marked "NO USAR" or covered by black blocks have no row.

## Inconsistencies in the sample

They are useful for testing validation. They do not indicate an irregularity: they may be
entry or reading errors, and the provisional count is not the final result.

| Telegram | Column | What happens |
| --- | --- | --- |
| `2015/060010004_0054.pdf` | PRES | One party is empty; written total 285, the sum is 69 |
| `2017/020840711D00167.pdf` | DIP | One list says 8, but the party total requires 81 |
| `2017/030120103_00767.pdf` | PRO | The sum is 241 and there are 236 envelopes |
| `2017/040010005A00373.pdf` | DIP | Written total 230, but 229 voters and 229 envelopes |
| `2017/030060051_00526.pdf`, `2017/030130124_00836.pdf` | All | Illegible header: no total to check against |
