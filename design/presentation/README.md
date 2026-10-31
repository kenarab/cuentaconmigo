# Presentación del proyecto (Beamer)

`cuentaconmigo.tex`: 10 diapositivas 16:9 con vistas de la app (maquetas TikZ) y
funcionalidades futuras rotuladas "PRÓXIMAMENTE · maqueta". **Versión preliminar**
para que el autor la corrija. Portada: usa `../cover/cover.png` si existe.

## Compilar

```sh
cd design/presentation
pdflatex cuentaconmigo.tex
pdflatex cuentaconmigo.tex   # segunda pasada: numeración total y overlays TikZ
```

Resultado: `cuentaconmigo.pdf`. Los archivos auxiliares (`.aux`, `.log`, `.nav`,
`.out`, `.snm`, `.toc`) se pueden borrar.

## Requisitos

Sólo paquetes estándar de TeX Live: `beamer`, `tikz`/`pgf`, `xcolor`, `babel`
(español), `lmodern`, `pifont`, `amssymb`, `etoolbox`, `graphicx`, `hyperref`.
No usa `pgfplots` (el gráfico de la simulación está dibujado con TikZ puro).

En este equipo sólo está `texlive-latex-base` (falta `beamer.cls`, `tikz.sty`,
`xcolor.sty` y `spanish.ldf`), así que **el `.tex` no se compiló acá**: se revisó
la sintaxis (balance de llaves y entornos, caracteres UTF-8 admitidos). Para
compilar hace falta instalar, con autorización del autor:

- Debian/Ubuntu: `texlive-latex-recommended` (beamer, pgf/tikz, xcolor),
  `texlive-lang-spanish` (babel español), `texlive-fonts-recommended` (lmodern,
  pifont) y `texlive-latex-extra` por las dudas.
- macOS (MacTeX / BasicTeX): `tlmgr install beamer pgf xcolor babel-spanish lm`.

## Qué revisar al corregir

- Diapositiva 6: números medidos en `sdd/specs/amba-simulation/SPEC.md`.
- Diapositiva 7: medición provisoria del OCR (72,4 %) en `sdd/specs/scrutiny-backend/SPEC.md`.
- Diapositivas 4, 5 y 8: todas las maquetas usan "Lista A/B/C (ficticia)" y
  números de ejemplo; no hay datos personales ni fuerzas reales.
