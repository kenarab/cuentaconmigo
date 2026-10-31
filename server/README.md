# Backend de escrutinio (prototipo)

Prototipo de [scrutiny-backend](../sdd/specs/scrutiny-backend/SPEC.md): ingesta de
capturas, evidencia inmutable por SHA-256 y OCR en el servidor con Tesseract. Sólo
biblioteca estándar de Python, sin instalaciones. FastAPI (SB-1 ★) puede reemplazar la
capa HTTP sin cambiar la API `/v1`.

```sh
python3 server/scrutiny_server.py          # http://127.0.0.1:8740, imprime el código de alta
```

Exponerlo en Internet (autor): detrás de un proxy inverso con HTTPS y

```sh
CC_PUBLIC=1 CC_TRUST_PROXY=1 CC_ENROLL_CODES_FILE=/ruta/codigos.txt python3 server/scrutiny_server.py
```

`codigos.txt` tiene un código de alta por línea; cada uno sirve una sola vez. Detalle de
seguridad y comprobantes en la SPEC. Contrato: `contracts/api/scrutiny-v1.openapi.json`.

Endpoints implementados: `GET /v1/health`, `GET /v1/ocr/engines`,
`POST /v1/devices/enroll`, `POST /v1/captures` (devuelve `missingBlobs`),
`PUT /v1/blobs/{sha256}` (verifica el hash, archivo de sólo lectura),
`GET /v1/captures/{id}`, `GET /v1/captures/{id}/ocr` (números detectados, siempre
`origin: "ocr"`) y `GET /v1/log/head` (cabeza del registro de comprobantes).

- **Seguridad:** el dispositivo sale del token y nunca de la ruta. Errores en formato
  RFC 9457. Por defecto escucha sólo en 127.0.0.1. El acceso desde afuera lo configura
  el autor, con TLS y límites de tasa (SPEC §7).
- **Datos:** `.runtime/scrutiny/` (ignorado por Git), con SQLite y blobs.
- **Falta:** revisión humana y doble carga, espejo oficial, conteo rápido y embargo.
