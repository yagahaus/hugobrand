# Hugo Álvarez — Branding & Editorial Web

Plataforma y prototipo de identidad visual, propuesta de branding y publicaciones editoriales para el Ing. **Hugo Álvarez Carbajal** (Salina Cruz, Oaxaca).

* **Repositorio Oficial:** [`yagahaus/hugobrand`](https://github.com/yagahaus/hugobrand)
* **URL en Producción:** [https://brand.hugo.dimedia.dev/](https://brand.hugo.dimedia.dev/)
* **Infraestructura:** Contenedor Docker `hugo_brand_web` (`nginx:alpine`) en servidor `tlon_cloud` (`209.38.142.8`) bajo Traefik v3.
* **Stack:** [Astro](https://astro.build/) (generador de sitios estáticos, Node >= 22).

---

## 🧞 Comandos Canónicos

| Comando | Acción |
| :--- | :--- |
| `npm install` | Instala dependencias del proyecto |
| `npm run dev` | Inicia el servidor de desarrollo local en `http://localhost:4321/` |
| `npm run build` | Compila el sitio estático para producción en `./dist/` |
| `npm run preview` | Previsualiza el build localmente |
| `npm run deploy` | Actualiza, compila y despliega a producción en `tlon_cloud` (vía script local) |

---

## 🚀 Despliegue a Producción

Este proyecto cuenta con dos métodos de despliegue:

### 1. Despliegue Automático (CI/CD con GitHub Actions)
Configurado en [`.github/workflows/deploy.yml`](.github/workflows/deploy.yml). Cada vez que se hace `git push origin main` o un editor publica un artículo desde el CMS (/admin/):
1. GitHub Actions clona el repositorio e instala dependencias con Node 22.
2. Compila el sitio con `npm run build`.
3. Sincroniza `./dist/` hacia `tlon_cloud:/root/dev-docker/dock-hugo-brand/html/` vía rsync sobre SSH.
4. Recarga Nginx en caliente: `docker exec hugo_brand_web nginx -s reload`.
5. Ejecuta un healthcheck HTTP 200 en `https://brand.hugo.dimedia.dev/`.

### 2. Despliegue Local Supervisado (Script de respaldo)
Puedes ejecutar manualmente el script local:

```bash
npm run deploy
# o directamente:
./scripts/sincronizar_brand_hugo.sh [opciones]
```

#### Opciones del script:
* `-p`, `--skip-pull`: Omite el paso de `git pull origin main`.
* `-b`, `--skip-build`: Omite la compilación `npm run build` y sincroniza el `./dist/` actual.
* `-d`, `--dry-run`: Modo simulación; muestra los archivos que se transferirían sin aplicar cambios en el servidor.
* `-h`, `--help`: Muestra la ayuda interactiva.

---

## 📁 Estructura del Proyecto

```text
├── .github/workflows/       # Pipelines de CI/CD (deploy.yml)
├── public/                 # Activos estáticos, imágenes, fuentes e iconos
│   ├── admin/              # Decap CMS (config.yml, index.html)
│   └── assets/images/blog/ # Galería de imágenes para artículos de blog
├── scripts/                # Scripts de automatización y despliegue
│   └── sincronizar_brand_hugo.sh
├── src/
│   ├── components/         # Componentes Astro / UI reutilizables
│   ├── content/blog/       # Artículos en formato Markdown
│   ├── data/               # Archivos JSON de configuración y navegación
│   ├── layouts/            # Plantillas maestras de página
│   └── pages/              # Enrutamiento estático de Astro
└── dist/                   # Artefactos compilados listos para distribución
```

Para las directivas completas de automatización y directivas operativas para agentes de IA, consulta [`AGENTS.md`](./AGENTS.md).
