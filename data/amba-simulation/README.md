# Fuentes de la simulación del AMBA

`manifest.json` registra cada archivo descargado para
[amba-simulation](../../sdd/specs/amba-simulation/SPEC.md): URL, licencia, fecha de
descarga, tamaño y SHA-256, y los derivados con el script que los genera.

Los archivos están en `data/private/amba-simulation/` (fuera de Git, por tamaño).
Para reproducir: descargar cada URL a `raw/`, verificar el SHA-256 y correr
`scripts/amba-simulation/normalize.py` y `geography.py`. Los resultados por mesa no
contienen datos personales.

**Datos incluidos en el prototipo:** `scripts/amba-simulation/bundle.py` copia los dos
derivados (verificando su SHA-256 contra este manifiesto) a
`design/prototypes/simulacion-amba/data/{mesas,strata}.js`, que sí están en Git
(~1,7 MB, resultados oficiales públicos sin datos personales). Así la simulación abre
sola, también desde el disco (`file://`), sin descargar nada. Al regenerar los derivados,
volver a correr `bundle.py`.
