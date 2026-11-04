# Hugo Álvarez — Branding & Editorial Web

Plataforma y prototipo de identidad visual, propuesta de branding y publicaciones editoriales para el Ing. **Hugo Álvarez Carbajal** (Salina Cruz, Oaxaca).

* **URL en Producción:** [https://brand.hugo.dimedia.dev/](https://brand.hugo.dimedia.dev/)
* **Servidor:** Contenedor Docker `hugo_brand_web` en `tlon_cloud` (Nginx + Traefik v3).
* **Stack:** [Astro](https://astro.build/) (generador de sitios estáticos).

---

## 🧞 Comandos Canónicos

| Comando | Acción |
| :--- | :--- |
| `npm install` | Instala dependencias del proyecto |
| `npm run dev` | Inicia el servidor de desarrollo local en `http://localhost:4321/` |
| `npm run build` | Compila el sitio estático para producción en `./dist/` |
| `npm run preview` | Previsualiza el build localmente |
| `npm run deploy` | **Actualiza, compila y despliega a producción en `tlon_cloud`** |

---

## 🚀 Despliegue a Producción

El despliegue a producción está automatizado mediante el script local:

```bash
npm run deploy
# o directamente:
./scripts/sincronizar_brand_hugo.sh [opciones]
```

### Opciones del Script de Despliegue:
* `-p`, `--skip-pull`: Omite el paso de `git pull origin main`.
* `-b`, `--skip-build`: Omite la compilación `npm run build` y sincroniza el `./dist/` actual.
* `-d`, `--dry-run`: Modo simulación; muestra los archivos que se transferirían sin aplicar cambios en el servidor.
* `-h`, `--help`: Muestra la ayuda interactiva.

---

## 📁 Estructura del Proyecto

```text
├── public/                 # Activos estáticos, imágenes, fuentes e iconos
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

Para directivas de automatización y reglas de agentes de IA, consulta [`AGENTS.md`](./AGENTS.md).
