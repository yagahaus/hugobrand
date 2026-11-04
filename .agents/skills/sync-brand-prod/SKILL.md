---
name: sync-brand-prod
description: Sincroniza y despliega la propuesta de branding del repositorio hugoalvarez hacia producción en brand.hugo.dimedia.dev (servidor tlon_cloud, contenedor hugo_brand_web). Usar siempre que el usuario pida actualizar el repo y enviar a producción, o sincronizar branding.
---

# Procedimiento de Despliegue a Producción — Hugo Álvarez Branding

## Cuándo usar este Skill
Usar de inmediato cuando el usuario solicite:
* *"Actualiza el repo y enviar a producción"*
* *"Despliega a producción con el script que estamos usando"*
* *"Sincroniza branding a producción"*

## Regla de Oro
Este repositorio (`hugoalvarez`) despliega a **`https://brand.hugo.dimedia.dev/`** (contenedor Docker `hugo_brand_web` en `tlon_cloud`), **NUNCA** a AWS S3. El portal oficial en AWS pertenece al repositorio separado `hugoalvarezmx`.

## Ejecución Canónica

Ejecutar directamente desde la raíz del repositorio:

```bash
npm run deploy
```

O invocando el script:

```bash
./scripts/sincronizar_brand_hugo.sh
```

### Opciones Comunes:
* `--skip-pull`: Si el código ya fue actualizado con `git pull` previamente.
* `--dry-run`: Si se desea auditar la transferencia diferencial de archivos sin impactar el servidor remoto.

## Verificación de Salud
Tras la ejecución del script, verificar el código HTTP 200 en:
* [https://brand.hugo.dimedia.dev/](https://brand.hugo.dimedia.dev/)
