# Directivas Operativas para Agentes de IA — Hugo Álvarez Branding (`hugoalvarez`)

Este espacio de trabajo corresponde al repositorio **`hugoalvarez`** (propuesta de branding, identidad gráfica y prototipo editorial del Ing. Hugo Álvarez Carbajal, proyecto **MKT 499** de DiMedia).

Todo agente de IA (**Antigravity**, **Agy**, **Claude Code**, etc.) que opere en este repositorio debe cumplir de forma inmediata y obligatoria las siguientes reglas operativas:

---

## 🚀 1. Regla Canónica de Despliegue a Producción (Tarea Repetitiva)

> [!IMPORTANT]
> **REGLA DE ORO:** Este repositorio sincroniza **única y exclusivamente hacia `https://brand.hugo.dimedia.dev/`** (contenedor Docker `hugo_brand_web` en el servidor `tlon_cloud`).
> 
> **NO confundir con el repo gemelo `hugoalvarezmx`**, el cual opera en AWS S3 + CloudFront para el dominio `hugoalvarez.mx`.

### Procedimiento Automatizado Inmediato (Sin Demoras)
* **CI/CD Automatizado (GitHub Actions):** Todo `git push` a `main` (o cambios publicados desde el CMS) dispara automáticamente el workflow [`.github/workflows/deploy.yml`](.github/workflows/deploy.yml) que compila, sincroniza vía rsync a `tlon_cloud`, recarga Nginx y verifica el sitio.
* **Manual / Supervisado Local:** Cuando el usuario indique:
  * *"Actualiza el repo y enviar a producción"*
  * *"Despliega a producción"*
  * *"Sincroniza a producción"*
  * O cualquier instrucción análoga:

El agente puede hacer push a `main` o ejecutar el script local:

```bash
# Opción 1 (Vía npm script canónico):
npm run deploy

# Opción 2 (Ejecución directa del script):
./scripts/sincronizar_brand_hugo.sh
```

### Qué hace este script automáticamente:
1. **Paso 1 (Git Pull):** Actualiza el repositorio local desde `origin main` (con soporte para SSH y fallback seguro con GitHub CLI).
2. **Paso 2 (Build):** Compila el sitio estático de Astro (`npm run build`) generando `./dist/`.
3. **Paso 3 (Rsync):** Sincroniza incrementalmente `./dist/` hacia `tlon_cloud:/root/dev-docker/dock-hugo-brand/html/` con `--delete`.
4. **Paso 4 (Reload):** Recarga Nginx en caliente dentro del contenedor Docker (`docker exec hugo_brand_web nginx -s reload`).
5. **Paso 5 (Healthcheck):** Verifica la respuesta HTTP 200 en `https://brand.hugo.dimedia.dev/`.

*Banderas disponibles:*
- `-p`, `--skip-pull`: Omite el `git pull` si ya estás sobre los commits deseados.
- `-b`, `--skip-build`: Omite el build de Astro y usa el `dist/` existente.
- `-d`, `--dry-run`: Simula la transferencia de archivos sin aplicarla en el servidor.

---

## 🎯 2. Parámetros del Entorno de Producción

| Parámetro | Valor |
| :--- | :--- |
| **URL Pública** | [https://brand.hugo.dimedia.dev/](https://brand.hugo.dimedia.dev/) |
| **Servidor Remoto** | `tlon_cloud` (`209.38.142.8`) |
| **Ruta en Servidor** | `/root/dev-docker/dock-hugo-brand/html/` |
| **Contenedor Docker** | `hugo_brand_web` (imagen `nginx:alpine` en red Traefik v3) |
| **Script Local** | `./scripts/sincronizar_brand_hugo.sh` |
| **Script Respaldo** | `/Users/tlon/dmx-projects/mkt-499-hugo-sc/scripts/sincronizar_brand_hugo.sh` |

---

## 💻 3. Comandos de Desarrollo

```bash
# Servidor local de desarrollo
npm run dev

# Compilación estática
npm run build

# Previsualizar build local
npm run preview

# Desplegar a producción en tlon_cloud
npm run deploy
```

---

## 🛡️ 4. Directriz de Comunicación (Fase No Electoral)

* **Enfoque Estratégico:** Branding de liderazgo ciudadano, cultura del esfuerzo, vinculación deportiva, streetwear y conexión con la juventud / Gen Z, y emprendimiento local en Salina Cruz.
* **Prohibición:** No incluir llamados explícitos al voto ni referencias a cargos públicos de elección popular o partidos políticos.
