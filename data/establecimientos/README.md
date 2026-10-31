# Nómina de establecimientos de votación

`nomina-2025.json`: distrito → sección → establecimiento (código, nombre, dirección,
localidad) → mesas como rangos `[desde, hasta, circuito]`, de las legislativas 2025.
La usan las listas desplegables para identificar la mesa
([telegram-capture](../../sdd/specs/telegram-capture/SPEC.md), F-16).

- Fuente: Ministerio del Interior, datos abiertos, `elecciones_legislativas_2025.zip`
  (`localesDeVotacionyMesas.csv`; circuito tomado de `resultados2025.csv`). URL y
  SHA-256 dentro del JSON. La descarga original queda en `data/private/` por tamaño.
- Regenerar: `scripts/establecimientos/build_nomina.py`.
- 24 distritos, 17.292 establecimientos. **Sin coordenadas** en la fuente: la
  sugerencia por ubicación (F-15) necesita geocodificar las direcciones.
- La nómina de 2027 se publicará cerca de la elección; hasta entonces, 2025 es la
  referencia más cercana. Datos públicos, sin información personal.
