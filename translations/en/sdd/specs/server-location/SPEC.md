> Automatic English translation of [`sdd/specs/server-location/SPEC.md`](../../../../../sdd/specs/server-location/SPEC.md)
> at commit `76bb7ee`. The Spanish original prevails.

# SPEC · Scrutiny server location in the app

Requested by the author; drafted from Nexo (metodologia-ia), which operates the public proxy.
Status: **proposal; author acceptance pending.** Date: 31/10/2026.
Related to [scrutiny-backend](../scrutiny-backend/SPEC.md) (decision D-003 of
mobile-platform) and to the server screen in [app-screens](../app-screens/SPEC.md).

## 1. Problem

`ServerSettingsView` starts with `http://` and the example `http://192.168.1.99:8740`, so
every poll watcher has to type the address by hand. That leads to typos, to LAN addresses
that don't work over mobile data, and to testing over unencrypted HTTP. The author asked
for the app to come configured with the public server.

## 2. Current location

| Field | Value |
| --- | --- |
| Base URL | `https://newbery.duckdns.org/cuentaconmigo` |
| Health | `GET https://newbery.duckdns.org/cuentaconmigo/v1/health` → `{"status":"ok",...}` |
| API | `/v1/...` per `contracts/api/scrutiny-v1.openapi.json`, under the base URL |
| Transport | HTTPS (TLS 1.2+), Let's Encrypt certificate; no ATS exception needed |
| Operation | Nexo's Apache proxy to `127.0.0.1:8740`; backend operated by this session |

The base URL includes the `/cuentaconmigo` prefix. The client builds routes with
`appendingPathComponent`, which keeps that prefix. Do **not** use `URL(string:relativeTo:)`
with absolute paths such as `/v1/...`, because it would drop the prefix.

## 3. Required behavior

1. **Build-configurable default.** The URL lives in `Info.plist`, key `CCDefaultServerURL`,
   fed by a build setting (`CC_DEFAULT_SERVER_URL`). In Release and TestFlight it is the URL in
   section 2; in Debug it may stay the same or point to the LAN. Never hard-code it in views.
2. **Prefill.** `ServerSettingsView` shows `ServerSettings.url` if present; otherwise the
   default. The field stays editable, for alternative or test servers.
3. **Reset.** Add the action «Usar servidor predeterminado». It does not clear the token:
   changing servers requires a new enrollment.
4. **HTTPS required outside Debug.** In Release, reject `http://` with the message
   «La dirección tiene que empezar con https://».
5. **The enrollment code stays manual.** The code is single-use and handed out by the
   coordinator; it never goes in the binary, in `Info.plist` or in public links.
6. **Placeholder and help text** without LAN addresses; example
   `https://newbery.duckdns.org/cuentaconmigo`.
7. **Connection test** before enrollment: `GET /v1/health`. If it fails, show «No se pudo
   contactar al servidor» without exposing internal details.

## 4. Out of scope

- Automatic discovery or remote configuration of the URL.
- Changing the domain, certificate or proxy: Nexo operates them
  (`metodologia-ia/docs/cuentaconmigo-publicacion.md`). To move the server, Nexo gives notice
  and the build setting is updated.
- Backend persistence, quotas and security review: pending with each owner.

## 5. Verification

- Unit test: with base `https://host/cuentaconmigo`, `ScrutinyClient` requests
  `https://host/cuentaconmigo/v1/health`.
- Unit test: in Release an `http://` URL is rejected.
- Manual on TestFlight: clean install → Server shows the public URL → enrollment code →
  submit a test capture. Do it over WiFi and over mobile data.
- `GET /v1/health` from outside the local network returns 200 (`sh ops/activate-cuentaconmigo-publico.sh check`
  in metodologia-ia).

## 6. Legal risk

No new personal data: the URL is public and enrollment uses an anonymous single-use code.
The `electoral_counsel` check remains pending, as in scrutiny-backend.
