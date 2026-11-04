#!/usr/bin/env bash
# ==============================================================================
# sincronizar_brand_hugo.sh
# ------------------------------------------------------------------------------
# Automatización local supervisada para sincronizar la propuesta de branding
# de Hugo Álvarez con el contenedor de producción en tlon_cloud.
#
# Flujo:
#   1. Git pull en el repositorio local (hugoalvarez)
#   2. Compilación estática con Astro (npm run build)
#   3. Transferencia diferencial vía rsync a tlon_cloud
#   4. Recarga de Nginx en el contenedor hugo_brand_web
#   5. Verificación HTTP (Healthcheck) en https://brand.hugo.dimedia.dev/
# ==============================================================================

set -euo pipefail

# Colores y formatos
BOLD=$'\033[1m'
GREEN=$'\033[0;32m'
BLUE=$'\033[0;34m'
YELLOW=$'\033[0;33m'
RED=$'\033[0;31m'
CYAN=$'\033[0;36m'
RESET=$'\033[0m'

# Configuración de rutas y destinos
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="${REPO_DIR:-$(cd "${SCRIPT_DIR}/.." && pwd)}"
DIST_DIR="${REPO_DIR}/dist"
REMOTE_HOST="${REMOTE_HOST:-tlon_cloud}"
REMOTE_DEST="${REMOTE_DEST:-/root/dev-docker/dock-hugo-brand/html/}"
CONTAINER_NAME="hugo_brand_web"
LIVE_URL="https://brand.hugo.dimedia.dev/"

# Opciones por defecto
SKIP_PULL=false
SKIP_BUILD=false
DRY_RUN=false

imprimir_ayuda() {
    cat << EOF
${BOLD}Uso:${RESET} $(basename "$0") [opciones]

${BOLD}Opciones:${RESET}
  -p, --skip-pull    Omite el paso de 'git pull' (usa el código local actual)
  -b, --skip-build   Omite 'npm run build' (sincroniza el dist/ existente)
  -d, --dry-run      Muestra los archivos que se transferirían sin aplicar cambios
  -h, --help         Muestra esta ayuda

${BOLD}Ejemplos:${RESET}
  $(basename "$0")              # Flujo completo: pull + build + rsync + reload + test
  $(basename "$0") --skip-pull  # Solo compila y sube cambios locales
  $(basename "$0") --dry-run    # Simula la transferencia rsync sin subir
EOF
}

# Procesar banderas
while [[ $# -gt 0 ]]; do
    case "$1" in
        -p|--skip-pull)
            SKIP_PULL=true
            shift
            ;;
        -b|--skip-build)
            SKIP_BUILD=true
            shift
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            imprimir_ayuda
            exit 0
            ;;
        *)
            echo -e "${RED}Opción desconocida: $1${RESET}"
            imprimir_ayuda
            exit 1
            ;;
    esac
done

echo -e "\n${BOLD}${CYAN}=== Sincronización de Branding Hugo Álvarez -> Producción ===${RESET}"
echo -e "${BLUE}Repositorio:${RESET} ${REPO_DIR}"
echo -e "${BLUE}Destino:${RESET}     ${REMOTE_HOST}:${REMOTE_DEST}"
echo -e "${BLUE}URL Pública:${RESET} ${LIVE_URL}\n"

# 0. Preparar entorno (fnm / node / npm)
export PATH="/opt/homebrew/bin:/usr/local/bin:$HOME/.local/bin:$HOME/Library/Application Support/reflex/bun/bin:$PATH"
if command -v fnm >/dev/null 2>&1; then
    eval "$(fnm env 2>/dev/null || true)"
fi

if [ ! -d "${REPO_DIR}" ]; then
    echo -e "${RED}❌ Error: No se encontró el repositorio en ${REPO_DIR}${RESET}"
    exit 1
fi

cd "${REPO_DIR}"

# 1. Actualizar repositorio (Git Pull)
if [ "${SKIP_PULL}" = false ]; then
    echo -e "${BOLD}[1/5] Actualizando repositorio con cambios remotos (git pull)...${RESET}"
    
    # Comprobar si hay cambios locales no guardados
    if ! git diff-index --quiet HEAD --; then
        echo -e "${YELLOW}⚠️  Advertencia: Hay modificaciones locales sin commitear en el repositorio.${RESET}"
    fi
    
    # Intentar git pull estándar; si falla por credenciales/agente, usar gh auth token si está disponible
    if ! git pull origin main 2>/dev/null; then
        if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
            echo -e "${YELLOW}Usando autenticación vía GitHub CLI (gh)...${RESET}"
            git pull "https://x-access-token:$(gh auth token)@github.com/cesarleyto/hugoalvarez.git" main
        else
            echo -e "${RED}❌ Error al ejecutar git pull origin main.${RESET}"
            exit 1
        fi
    fi
    echo -e "${GREEN}✓ Repositorio actualizado.${RESET}\n"
else
    echo -e "${YELLOW}[1/5] Omitiendo git pull (--skip-pull activado).${RESET}\n"
fi

# 2. Compilar con Astro (Build)
if [ "${SKIP_BUILD}" = false ]; then
    echo -e "${BOLD}[2/5] Compilando sitio estático con Astro (npm run build)...${RESET}"
    
    # Comprobar que npm esté disponible
    if ! command -v npm >/dev/null 2>&1; then
        echo -e "${RED}❌ Error: No se encontró 'npm' en el PATH.${RESET}"
        exit 1
    fi
    
    npm run build
    
    if [ ! -f "${DIST_DIR}/index.html" ]; then
        echo -e "${RED}❌ Error: La compilación no generó ${DIST_DIR}/index.html.${RESET}"
        exit 1
    fi
    echo -e "${GREEN}✓ Build completado exitosamente en ${DIST_DIR}.${RESET}\n"
else
    echo -e "${YELLOW}[2/5] Omitiendo build (--skip-build activado). Usando dist/ existente.${RESET}\n"
    if [ ! -f "${DIST_DIR}/index.html" ]; then
        echo -e "${RED}❌ Error: No existe ${DIST_DIR}/index.html. Debes compilar al menos una vez.${RESET}"
        exit 1
    fi
fi

# 3. Sincronizar vía Rsync con tlon_cloud
echo -e "${BOLD}[3/5] Sincronizando archivos con el servidor cloud...${RESET}"
RSYNC_FLAGS="-avz --delete"
if [ "${DRY_RUN}" = true ]; then
    RSYNC_FLAGS="${RSYNC_FLAGS} --dry-run"
    echo -e "${YELLOW}(Modo simulación --dry-run activo: no se modificarán archivos en el servidor)${RESET}"
fi

rsync ${RSYNC_FLAGS} "${DIST_DIR}/" "${REMOTE_HOST}:${REMOTE_DEST}"
echo -e "${GREEN}✓ Transferencia completada.${RESET}\n"

if [ "${DRY_RUN}" = true ]; then
    echo -e "${CYAN}Simulación completada. No se aplicó recarga de Nginx ni verificación.${RESET}"
    exit 0
fi

# 4. Recargar Nginx en el contenedor
echo -e "${BOLD}[4/5] Recargando Nginx en contenedor ${CONTAINER_NAME}...${RESET}"
ssh "${REMOTE_HOST}" "docker exec ${CONTAINER_NAME} nginx -s reload"
echo -e "${GREEN}✓ Servidor Nginx recargado.${RESET}\n"

# 5. Verificación de salud HTTP
echo -e "${BOLD}[5/5] Verificando respuesta en vivo (${LIVE_URL})...${RESET}"
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "${LIVE_URL}")

if [ "${HTTP_STATUS}" -eq 200 ]; then
    echo -e "${GREEN}${BOLD}🎉 ¡Éxito! Sitio web actualizado y respondiendo HTTP 200 OK.${RESET}"
    echo -e "👉 Visita: ${BOLD}${LIVE_URL}${RESET}\n"
else
    echo -e "${YELLOW}⚠️  Aviso: El sitio respondió con código HTTP ${HTTP_STATUS}. Revisa los logs en ${REMOTE_HOST}.${RESET}\n"
fi
