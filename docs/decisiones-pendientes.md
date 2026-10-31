# Decisiones pendientes del autor · 31/10/2026

Tablero: [GitHub Project](https://github.com/users/kenarab/projects/2), con Tipo =
Decisión. Las de la hackatón se responden en los issues #1-#9 (pipeline de
[human-in-the-loop](../sdd/specs/human-in-the-loop/SPEC.md)); las nuevas de hoy están
en las SPECs con su recomendación ★.

## Para destrabar el trabajo ya

| Decisión | Qué destraba | Recomendación ★ | Dónde |
| --- | --- | --- | --- |
| #1 F-P0, F-ORD | Qué se muestra a las 17:45 | b) escrutinio + simulación AMBA; la red como visión | [#1](https://github.com/kenarab/cuentaconmigo/issues/1) |
| #2 AS-1..AS-12 | Pantallas del escrutinio (Andy ya respondió) | Ver comentario de Andy | [#2](https://github.com/kenarab/cuentaconmigo/issues/2) |
| #3 S-1..S-3 | Simulación AMBA (hoy con ★ provisorias) | Web estática, polígonos oficiales, estratificado | [#3](https://github.com/kenarab/cuentaconmigo/issues/3) |
| #23 ⛔ legales | Uso con datos reales de identidad y fiscales | TC-11 ★, FP-3 anónima, decidir TC-5/TC-12 | [#23](https://github.com/kenarab/cuentaconmigo/issues/23) |
| SB-1, SB-2 + permiso de instalación | Backend y OCR en servidor (#18) | Python + FastAPI + SQLite; Tesseract | [scrutiny-backend](../sdd/specs/scrutiny-backend/SPEC.md) |
| AA-2, AA-3, AA-5 | Prototipo de 3 diseños (#14) y app modular | Flujo en `contracts/flows`, mismo JSON en el prototipo, F-1+F-2 completas | [app-architecture](../sdd/specs/app-architecture/SPEC.md) |
| swift-crypto | Tests del núcleo en Linux | Dependencia sólo para Linux, o lo corrés vos con `!` | conversación del 31/10 |

## Después de la hackatón

| SPEC | IDs | Tema |
| --- | --- | --- |
| [network-governance](../sdd/specs/network-governance/SPEC.md) | NG-1..NG-20 | DAO sin token, reputación, reglas, evaluaciones colegiadas |
| [trust-chain-identity](../sdd/specs/trust-chain-identity/SPEC.md) | TC-1..TC-15 | Alta por QR, niveles, grafos, partidos, perfiles públicos |
| [scrutiny-backend](../sdd/specs/scrutiny-backend/SPEC.md) | SB-3..SB-15 | OCR, conteo rápido, embargo, escala |
| [app-architecture](../sdd/specs/app-architecture/SPEC.md) | AA-1, AA-4, AA-6..AA-9 | Patrón Swift, tokens, núcleo Rust |
| [fiscal-planning](../sdd/specs/fiscal-planning/SPEC.md) | FP-1..FP-6 | Modo planificación de fiscales |
| [amba-simulation](../sdd/specs/amba-simulation/SPEC.md) | S-1..S-3 | Plataforma, geografía, modelo |
| [mobile-platform](../sdd/specs/mobile-platform/SPEC.md) | D-001..D-003 | Plataforma móvil y backend |

Disensos que requieren criterio del autor: algoritmo de puente vs. dato sensible
(NG-5), sorteo o elección para roles sensibles (NG-10), vida media de la reputación
(NG-16), perfiles públicos (TC-15/NG-20).

Preguntas para abogado/a electoral y profesional de seguridad: en cada
`sdd/specs/*/checks/electoral_counsel.md` y en
[network-governance/deliberation/03-legal-security.md](../sdd/specs/network-governance/deliberation/03-legal-security.md).
