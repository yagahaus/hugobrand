# Directivas Operativas para Agentes de IA — Hugo Álvarez Branding (`hugobrand` / `hugoalvarez`)

Este espacio de trabajo corresponde al repositorio **`hugobrand`** (propuesta de branding, identidad gráfica y prototipo editorial del Ing. Hugo Álvarez Carbajal, proyecto **MKT 499** de DiMedia), alojado en la organización GitHub:
👉 **`https://github.com/yagahaus/hugobrand`**

Todo agente de IA (**Antigravity**, **Agy**, **Claude Code**, **Cursor**, etc.) que opere en este repositorio debe cumplir de forma obligatoria las siguientes directivas de arquitectura y despliegue:

---

## 🚀 1. Especificaciones de Despliegue y Arquitectura de Producción

> [!IMPORTANT]
> **REGLA DE ORO DE PRODUCCIÓN:**
> Este repositorio sincroniza **única y exclusivamente hacia `https://brand.hugo.dimedia.dev/`** (contenedor Docker `hugo_brand_web` en el servidor `tlon_cloud`).
> 
> **NO confundir con el repo gemelo `hugoalvarezmx`**, el cual opera en AWS S3 + CloudFront para el portal oficial `hugoalvarez.mx`.

### 📊 Ficha Técnica del Entorno

| Parámetro | Valor / Especificación |
| :--- | :--- |
| **Repositorio GitHub** | `yagahaus/hugobrand` (rama principal: `main`) |
| **URL Pública en Vivo** | [https://brand.hugo.dimedia.dev/](https://brand.hugo.dimedia.dev/) |
| **Servidor Físico / Cloud**| `tlon_cloud` (DigitalOcean Droplet IP `209.38.142.8`) |
| **Ruta Remota en Servidor** | `/root/dev-docker/dock-hugo-brand/html/` |
| **Contenedor Docker** | `hugo_brand_web` (imagen `nginx:alpine`) |
| **Orquestador / Proxy** | Traefik v3 con terminación SSL/TLS automática |
| **Comando de Recarga** | `docker exec hugo_brand_web nginx -s reload` |
| **Herramienta de Build** | Astro v6+ (`npm run build` genera `./dist/`, requiere Node.js `>=22.12.0`) |
| **Método de Transferencia**| `rsync -avz --delete` vía SSH |
| **Healthcheck** | HTTP 200 en `https://brand.hugo.dimedia.dev/` |

---

## ⚙️ 2. Mecanismos de Despliegue (Cómo Desplegar)

Existen dos vías de despliegue coordinadas:

### Vía A: CI/CD Automático en GitHub Actions (Vía Primaria)
* **Archivo de Workflow:** [`.github/workflows/deploy.yml`](.github/workflows/deploy.yml)
* **Disparadores (Triggers):**
  1. Todo `git push` a la rama `main` (incluyendo merges de pull requests).
  2. Publicaciones de contenido desde el CMS editorial Decap CMS (`/admin/`).
  3. Ejecución manual vía `workflow_dispatch` (mediante GitHub UI o `gh workflow run deploy.yml`).
* **Secretos de GitHub configurados en `yagahaus/hugobrand`:**
  - `SSH_HOST`: `209.38.142.8`
  - `SSH_USER`: `root`
  - `SSH_PRIVATE_KEY`: Clave SSH Ed25519 dedicada (`github-actions-deploy-hugobrand`). Su contraparte pública está autorizada en `/root/.ssh/authorized_keys` de `tlon_cloud`.
* **Pipeline:**
  1. `actions/checkout@v4`
  2. `actions/setup-node@v4` (Node.js 22 con cache npm)
  3. `npm ci`
  4. `npm run build`
  5. `webfactory/ssh-agent@v0.9.0` con la clave privada Ed25519
  6. Registro de host en `known_hosts` con `ssh-keyscan`
  7. `rsync -avz --delete dist/ root@209.38.142.8:/root/dev-docker/dock-hugo-brand/html/`
  8. `ssh root@209.38.142.8 "docker exec hugo_brand_web nginx -s reload"`
  9. Comprobación de salud HTTP 200 con `curl`

### Vía B: Script Local Supervisado (Fallback / Respaldo)
Si no se desea o no se puede esperar al pipeline de GitHub, o se requiere sincronizar cambios directamente desde la máquina local:

```bash
# Opción canónica recomendada:
npm run deploy

# O invocación directa:
./scripts/sincronizar_brand_hugo.sh [banderas]
```

*Banderas disponibles:*
- `-p`, `--skip-pull`: Omite `git pull` (usa el código local actual).
- `-b`, `--skip-build`: Omite `npm run build` y sincroniza el `./dist/` existente.
- `-d`, `--dry-run`: Simula la transferencia de archivos sin aplicarla en el servidor.
- `-h`, `--help`: Muestra la ayuda interactiva.

---

## 🤖 3. Protocolo Operativo para Agentes de IA

Cuando el usuario dé instrucciones como:
* *"Despliega a producción"*
* *"Sube los cambios"*
* *"Actualiza el sitio"*
* *"Envía a producción"*

El agente debe:
1. **Verificar estado de Git:** Asegurarse de que no queden archivos sin commitear relevantes.
2. **Hacer Push o Ejecutar Deploy:**
   * Si los cambios se commitean y se hace `git push origin main`, **GitHub Actions desplegará automáticamente**. El agente puede monitorear el run con:
     ```bash
     gh run list --repo yagahaus/hugobrand --limit 1
     gh run watch <run_id> --repo yagahaus/hugobrand
     ```
   * Si el usuario pide un despliegue local inmediato o supervisado, ejecutar directamente:
     ```bash
     npm run deploy
     ```
3. **Validación:** Confirmar siempre la respuesta HTTP 200 en `https://brand.hugo.dimedia.dev/`.

---

## 💻 4. Comandos de Desarrollo Local

```bash
# Instalar dependencias
npm install

# Servidor local de desarrollo (http://localhost:4321/)
npm run dev

# Compilación estática local (genera ./dist/)
npm run build

# Previsualizar build local
npm run preview

# Desplegar localmente a producción
npm run deploy
```

---

## 🛡️ 5. Directriz de Comunicación y Contenido (Fase No Electoral)

* **Enfoque Estratégico:** Branding de liderazgo ciudadano, cultura del esfuerzo, vinculación deportiva, streetwear y conexión con la juventud / Gen Z, y emprendimiento local en Salina Cruz.
* **Prohibición:** No incluir llamados explícitos al voto ni referencias a cargos públicos de elección popular o partidos políticos.
