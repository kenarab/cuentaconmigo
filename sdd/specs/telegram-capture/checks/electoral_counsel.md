# Chequeo electoral_counsel (legal, datos personales y ciberseguridad) · telegram-capture

## 31/10/2026

> No es asesoramiento legal ni de seguridad profesional.

### 1. Alcance

- Revisión `1dd5c8f`. `sdd/specs/telegram-capture/SPEC.md`;
  `contracts/templates/generales-2023.json`, `balotaje-2015.json`, `demo-2027.json`
  (listado); `data/ocr-samples/` (README, manifest y planillas en Git; PDFs fuera).
- Normas verificadas hoy: Código Electoral art. 71 incs. g y h (Infoleg). Ley 25.326
  arts. 2, 5, 7 (Infoleg). Arts. 101-105 según MARCO_LEGAL (verificados allí).

### 2. Modelo de amenazas (resumen)

- **Activos:** fotos de telegramas/actas/certificados en el teléfono; valores
  transcriptos; paquete exportado (JSON + JPEG + hashes).
- **Actores:** quien roba o revisa el teléfono; quien fabrica o edita un paquete y lo
  hace circular como evidencia; quien saca de contexto una captura.
- **Superficie:** almacenamiento local, importación desde Fotos, exportación por el menú
  de compartir, plantillas declarativas.

### 3. Hallazgos

| # | Sev. | Hallazgo | Base / control |
| --- | --- | --- | --- |
| L1 | ✅ | Advertencia previa sobre la Boleta Única y sólo tres tipos de documento admitidos. | Art. 71 inc. g (verificado: dirigido "a los electores", durante los comicios). |
| L2 | ⚠️ | **L-1 sigue abierta:** fotografiar certificado/telegrama no está prohibido ni autorizado expresamente. Además, el uso por **autoridades de mesa** (funcionarios del acto) de una app privada no está regulado. | MARCO_LEGAL §3.2 y preguntas 1-2. Pregunta prioritaria para abogado/a. |
| L3 | ✅ | Plantillas con nombres reales de agrupaciones (2023, 2015): son datos oficiales públicos, en orden por número de lista, con el mismo tratamiento para todas. Neutralidad correcta. Falta cotejar las filas de 2023 con un telegrama real (lo dice la SPEC). | Ley 27.275 (MARCO_LEGAL). |
| L4 | ⚠️ | **Fotos con datos sensibles:** nombres, firmas y DNI de autoridades y de fiscales asociados a su partido (arts. 2 y 7 inc. 3). En P0 quedan en el teléfono (correcto). La exportación las distribuye sin tapar. | Control: aviso al exportar (previsto en fiscal-planning, sumarlo aquí) y opción de exportar con bloques de firmas tapados (paquete derivado con su propio hash, el original intacto). |
| L5 | ✅ | `data/ocr-samples`: PDFs fuera de Git por contener nombres y firmas (README); en Git sólo URLs públicas, hashes y valores transcriptos. Una nota menciona "una firma" sin datos personales. | Verificado hoy con `git ls-files data`. |
| S1 | ⚠️ | **EXIF de ubicación** en imágenes importadas desde Fotos: quedarían dentro del original "inmutable" y del paquete exportado, revelando dónde estuvo la persona. | Quitar metadatos de ubicación antes de guardar y hashear (registrar la transformación en el paquete) o rechazar imágenes con GPS (MASVS-PRIVACY). |
| S2 | ⚠️ | **Paquetes fabricados:** el hash prueba integridad, no autoría; un paquete editado con hashes recalculados es indistinguible. | SB-8 (firma con clave del dispositivo) antes de uso real; en P0, rotular "sin firma de dispositivo". |
| S3 | ✅ | Data Protection `complete`, sin respaldo en iCloud, sólo permiso de cámara, selector de Fotos sin permiso amplio, sin red en P0. | MASVS-STORAGE, MASVS-PLATFORM. |
| S4 | ⚠️ bajo | Plantillas cargadas como datos: si en el futuro se descargan, una plantilla maliciosa podría alterar filas o reglas. | Plantillas embebidas o firmadas; validación contra schema. |

### 4. Alternativas

- **L4 exportación:** (1) exportación por defecto tapada + original sólo a pedido con
  advertencia; (2) advertencia sola; (3) exportación completa sin aviso (actual).
- **S1 EXIF:** (1) quitar GPS en la importación y registrarlo; (2) rechazar con GPS;
  (3) conservar (no recomendado).

### 5. Recomendaciones

1. Mantener L-1 como pregunta prioritaria antes de cualquier prueba de campo.
2. Aviso de datos personales al exportar y opción tapada (L4).
3. Quitar EXIF de ubicación en la importación (S1).
4. Rótulo "sin firma de dispositivo" hasta SB-8.

### 6. No verificado

- Autorización o prohibición de fotografiar certificado/telegrama (L-1).
- Formato oficial 2027 (Q1).

### Veredicto

**✅ con observaciones (⚠️)**: sin ⛔ para el prototipo P0. Riesgo principal: L-1 sin
respuesta legal y distribución de imágenes con datos sensibles al exportar.
