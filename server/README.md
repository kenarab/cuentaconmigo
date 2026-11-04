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

### Prender y apagar el servidor público de prueba

Configuración actual de `newbery.duckdns.org/cuentaconmigo` (proxy → `127.0.0.1:8740`):

```sh
cd ~/home.agents/git/cuentaconmigo
nohup env CC_PUBLIC=1 CC_TRUST_PROXY=1 CC_OPEN_TEST=1 \
  CC_ENROLL_CODES_FILE=$PWD/.private/scrutiny-codes.txt CC_APP_ENROLL_CODE=0000 \
  CC_HOST=127.0.0.1 CC_PORT=8740 python3 -E -s server/scrutiny_server.py \
  > ~/home.codex/tmp/scrutiny.log 2>&1 &
curl https://newbery.duckdns.org/cuentaconmigo/v1/health   # "status": "ok"
pkill -f scrutiny_server.py                                  # apagar
```

- `python3 -E -s` y no `-I`: con `-I` no importa `server/readings.py`.
- `CC_OPEN_TEST=1` y `CC_APP_ENROLL_CODE=0000` son **modo de prueba** (alta con "0000").
  Sacarlos antes de usar datos reales.
- Sin `nohup … &` corre en la terminal y se apaga con `Ctrl+C`.

`codigos.txt` tiene un código de alta por línea; cada uno sirve una sola vez. Detalle de
seguridad y comprobantes en la SPEC. Contrato: `contracts/api/scrutiny-v1.openapi.json`.

Endpoints implementados: `GET /v1/health`, `GET /v1/ocr/engines`,
`POST /v1/devices/enroll`, `POST /v1/captures` (devuelve `missingBlobs`),
`PUT /v1/blobs/{sha256}` (verifica el hash, archivo de sólo lectura),
`GET /v1/captures/{id}`, `GET /v1/captures/{id}/ocr` (números detectados, siempre
`origin: "ocr"`), `GET /v1/log/head` (cabeza del registro de comprobantes) y `POST /v1/readings?templateId=…`
(imagen JPEG → lectura por celda alineada a la diagramación de `contracts/layouts/`, con
confianza y cajas; no guarda la imagen; ver `sdd/specs/form-layouts/SPEC.md`).
Medición: `python3 server/eval_readings.py`. Necesita Pillow (`python3 -c "import PIL"`).

- **Seguridad:** el dispositivo sale del token y nunca de la ruta. Errores en formato
  RFC 9457. Por defecto escucha sólo en 127.0.0.1. El acceso desde afuera lo configura
  el autor, con TLS y límites de tasa (SPEC §7).
- **Datos:** `.runtime/scrutiny/` (ignorado por Git), con SQLite y blobs.
- **Falta:** revisión humana y doble carga, espejo oficial, conteo rápido y embargo.
