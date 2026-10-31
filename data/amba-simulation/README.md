# Fuentes de la simulación del AMBA

`manifest.json` registra cada archivo descargado para
[amba-simulation](../../sdd/specs/amba-simulation/SPEC.md): URL, licencia, fecha de
descarga, tamaño y SHA-256, y los derivados con el script que los genera.

Los archivos están en `data/private/amba-simulation/` (fuera de Git, por tamaño).
Para reproducir: descargar cada URL a `raw/`, verificar el SHA-256 y correr
`scripts/amba-simulation/normalize.py` y `geography.py`. Los resultados por mesa no
contienen datos personales.
