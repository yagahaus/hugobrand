---
name: sync-brand-prod
description: Sincroniza y despliega la propuesta de branding del repositorio hugoalvarez (hugobrand) hacia producción en brand.hugo.dimedia.dev (servidor tlon_cloud, contenedor hugo_brand_web). Usar siempre que el usuario pida actualizar el repo y enviar a producción, o sincronizar branding.
---

# Procedimiento de Despliegue a Producción — Hugo Álvarez Branding

## Cuándo usar este Skill
Usar de inmediato cuando el usuario solicite:
* *"Actualiza el repo y enviar a producción"*
* *"Despliega a producción"*
* *"Sincroniza branding a producción"*

## Regla de Oro
Este repositorio (`yagahaus/hugobrand`) despliega **única y exclusivamente** a **`https://brand.hugo.dimedia.dev/`** (contenedor Docker `hugo_brand_web` en el servidor `tlon_cloud`), **NUNCA** a AWS S3. El portal oficial en AWS pertenece al repositorio separado `hugoalvarezmx`.

## Arquitectura de Despliegue

| Componente | Especificación |
| :--- | :--- |
| **Repositorio** | `yagahaus/hugobrand` (rama `main`) |
| **URL Producción** | https://brand.hugo.dimedia.dev/ |
| **Servidor Remoto** | `tlon_cloud` (`209.38.142.8`) |
| **Ruta Remota** | `/root/dev-docker/dock-hugo-brand/html/` |
| **Contenedor** | `hugo_brand_web` (`nginx:alpine`) |
| **Proxy / SSL** | Traefik v3 |
| **Recarga Nginx** | `docker exec hugo_brand_web nginx -s reload` |

## Modos de Ejecución

### Opción 1: Automático vía GitHub Actions (Recomendado)
Al hacer commit y push a `main`:
```bash
git push origin main
```
El workflow [`.github/workflows/deploy.yml`](../../.github/workflows/deploy.yml) se dispara automáticamente. Puedes monitorearlo con:
```bash
gh run list --repo yagahaus/hugobrand --limit 1
```

### Opción 2: Ejecución Local Supervisada (Fallback)
Ejecutar directamente desde la raíz del repositorio:
```bash
npm run deploy
```
O invocando el script:
```bash
./scripts/sincronizar_brand_hugo.sh [opciones]
```

### Opciones Comunes del Script:
* `--skip-pull`: Si el código ya fue actualizado con `git pull` previamente.
* `--dry-run`: Si se desea auditar la transferencia diferencial de archivos sin impactar el servidor remoto.

## Verificación de Salud
Tras la ejecución, verificar el código HTTP 200 en:
* [https://brand.hugo.dimedia.dev/](https://brand.hugo.dimedia.dev/)
