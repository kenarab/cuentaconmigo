---
name: contract-change
description: Cambiar contratos compartidos (contracts/ schemas, plantillas, vectores) que deben respetar iOS, Android y backend. Usar cuando cambie una regla de validación, el formato del paquete de captura o una plantilla de formulario.
---

# Cambio de contrato

Los contratos son la única fuente compartida entre plataformas
(`sdd/specs/mobile-platform/SPEC.md`).

1. Actualizar la SPEC que motiva el cambio (skill `sdd-change`).
2. Editar `contracts/` primero: schema, plantilla y **vectores** que demuestren la
   regla nueva (casos válidos e inválidos). Sólo datos ficticios.
3. Validar los JSON: `python3 -m json.tool <archivo> >/dev/null`.
4. Commit atómico de contratos + push.
5. Copiar al bundle iOS: `ios/scripts/sync-contracts.sh`.
6. Implementar en `ios/TelegramaCore` hasta que pasen los vectores
   (skill `ios-verify`). Commit + push.
7. Si existe `android/`, abrir tarea para que pase los mismos vectores. Una plataforma
   que no pasa los vectores no es conforme.
