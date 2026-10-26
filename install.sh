#!/bin/bash

SYS_LANG="${LANG%%_*}"
VERSION="1.1.0"
LOG_DIR="/var/log/dnpt"
LOG_FILE="$LOG_DIR/dnpt.log"

if [ "$SYS_LANG" = "es" ]; then
    MSG_ROOT="Por favor, ejecuta el script como root (sudo bash install.sh [opción])."
    MSG_STOP="Deteniendo servicios y procesos de Dnpt..."
    MSG_STOP_OK="Servicio systemd 'dnpt.service' detenido con éxito."
    MSG_STOP_NO="No se encontró un servicio systemd activo para Dnpt."
    MSG_UNINSTALL="Desinstalando Dnpt por completo..."
    MSG_UNINSTALL_SRV="Servicio systemd eliminado."
    MSG_UNINSTALL_WRAPPER="Wrappers 'apt' y 'dnpt' eliminados del sistema."
    MSG_UNINSTALL_LOGS="Registros y directorio de logs eliminados."
    MSG_UNINSTALL_NO="No se encontraron los binarios instalados."
    MSG_UNINSTALL_OK="¡Desinstalación completada con éxito!"
    MSG_LOGS_TITLE="REGISTROS DE ACTIVIDAD (LOGS)"
    MSG_LOGS_EMPTY="No hay registros de actividad todavía en: $LOG_FILE"
    MSG_HELP_USAGE="Uso: sudo bash install.sh [opción]"
    MSG_HELP_OPT="Opciones:"
    MSG_HELP_1="  (sin argumentos)  Instala Dnpt, muestra el banner y diagnóstico"
    MSG_HELP_2="  --stop            Detiene el servicio en segundo plano"
    MSG_HELP_3="  --uninstall       Desinstala Dnpt y limpia el sistema"
    MSG_HELP_4="  --version         Muestra la versión actual de Dnpt"
    MSG_HELP_5="  --logs            Muestra el historial de comandos ejecutados"
    MSG_BANNER_MISSING="Aviso: No se encontró 'banner.txt', omitiendo presentación visual."
    MSG_TITLE="INSTALADOR DE DNPT"
    MSG_ERR_DNPT="Error: No se encuentra el archivo principal 'dnpt.py' en este directorio."
    MSG_ERR_DNPT_HINT="Asegúrate de que tu script del wrapper se llame 'dnpt.py'."
    MSG_COPY="Instalando wrappers 'apt' y 'dnpt'..."
    MSG_INST_OK="¡Instalación completada con éxito!"
    MSG_READY="Dnpt activo. Ya puedes usar 'sudo apt' o 'sudo dnpt'."
    MSG_SYS_INFO="DIAGNÓSTICO DEL ENTORNO"
    MSG_DISTRO="Distribución"
    MSG_PKG_MGR="Gestor Base"
    MSG_TIMEZONE="Zona Horaria"
else
    MSG_ROOT="Please run the script as root (sudo bash install.sh [option])."
    MSG_STOP="Stopping Dnpt services and processes..."
    MSG_STOP_OK="Systemd service 'dnpt.service' stopped successfully."
    MSG_STOP_NO="No active systemd service found for Dnpt."
    MSG_UNINSTALL="Uninstalling Dnpt completely..."
    MSG_UNINSTALL_SRV="Systemd service removed."
    MSG_UNINSTALL_WRAPPER="Wrappers 'apt' and 'dnpt' removed from system."
    MSG_UNINSTALL_LOGS="Logs directory and records removed."
    MSG_UNINSTALL_NO="No installed binaries found."
    MSG_UNINSTALL_OK="Uninstallation completed successfully!"
    MSG_LOGS_TITLE="ACTIVITY LOGS"
    MSG_LOGS_EMPTY="No activity logs found yet at: $LOG_FILE"
    MSG_HELP_USAGE="Usage: sudo bash install.sh [option]"
    MSG_HELP_OPT="Options:"
    MSG_HELP_1="  (no arguments)    Installs Dnpt, shows banner & system info"
    MSG_HELP_2="  --stop            Stops the background service"
    MSG_HELP_3="  --uninstall       Uninstalls Dnpt and cleans the system"
    MSG_HELP_4="  --version         Shows current version of Dnpt"
    MSG_HELP_5="  --logs            Shows command execution history"
    MSG_BANNER_MISSING="Notice: 'banner.txt' not found, skipping visual presentation."
    MSG_TITLE="DNPT INSTALLER"
    MSG_ERR_DNPT="Error: Main script 'dnpt.py' not found in this directory."
    MSG_ERR_DNPT_HINT="Make sure your wrapper script is named 'dnpt.py'."
    MSG_COPY="Installing wrappers 'apt' and 'dnpt'..."
    MSG_INST_OK="Installation completed successfully!"
    MSG_READY="Dnpt active. You can now use 'sudo apt' or 'sudo dnpt'."
    MSG_SYS_INFO="ENVIRONMENT DIAGNOSTICS"
    MSG_DISTRO="Distribution"
    MSG_PKG_MGR="Package Manager"
    MSG_TIMEZONE="Timezone"
fi

if [ "$EUID" -ne 0 ]; then
  echo -e "\n\033[1;41m 󰅚 ERROR \033[0m \033[1;31m$MSG_ROOT\033[0m\n"
  exit 1
fi

ICON_LINUX="󰣛"
ICON_PKG="󰚰"
ICON_GEAR="󰒋"
ICON_CHECK="󰄬"
ICON_ERROR="󰅚"
ICON_INFO="󰋼"
ICON_STOP="󰓛"
ICON_SYS="󰌢"
ICON_ROCKET="󰚩"
ICON_LOG="󰌽"

case "$1" in
    --stop)
        echo -e "\n\033[1;33m${ICON_STOP} $MSG_STOP\033[0m"
        if systemctl list-unit-files | grep -q "dnpt.service"; then
            systemctl stop dnpt.service
            echo -e "\033[1;32m${ICON_CHECK} $MSG_STOP_OK\033[0m\n"
        else
            echo -e "\033[1;36m${ICON_INFO} $MSG_STOP_NO\033[0m\n"
        fi
        exit 0
        ;;
        
    --uninstall)
        echo -e "\n\033[1;31m${ICON_GEAR} $MSG_UNINSTALL\033[0m"
        if systemctl list-unit-files | grep -q "dnpt.service"; then
            systemctl stop dnpt.service
            systemctl disable dnpt.service
            rm -f /etc/systemd/system/dnpt.service
            systemctl daemon-reload
            echo -e "\033[1;32m${ICON_CHECK} $MSG_UNINSTALL_SRV\033[0m"
        fi
        if [ -f "/usr/local/bin/apt" ] || [ -f "/usr/local/bin/dnpt" ]; then
            rm -f /usr/local/bin/apt /usr/local/bin/dnpt
            echo -e "\033[1;32m${ICON_CHECK} $MSG_UNINSTALL_WRAPPER\033[0m"
        else
            echo -e "\033[1;36m${ICON_INFO} $MSG_UNINSTALL_NO\033[0m"
        fi
        if [ -d "$LOG_DIR" ]; then
            rm -rf "$LOG_DIR"
            echo -e "\033[1;32m${ICON_CHECK} $MSG_UNINSTALL_LOGS\033[0m"
        fi
        echo -e "\033[1;32m${ICON_CHECK} $MSG_UNINSTALL_OK\033[0m\n"
        exit 0
        ;;

    --version)
        echo -e "\n\033[1;36m󰏗 Dnpt (APT-to-DNF Wrapper) v$VERSION\033[0m\n"
        exit 0
        ;;

    --logs)
        echo -e "\n\033[1;34m${ICON_LOG} $MSG_LOGS_TITLE\033[0m"
        echo -e "\033[0;90m──────────────────────────────────────────────────\033[0m"
        if [ -f "$LOG_FILE" ]; then
            cat "$LOG_FILE"
        else
            echo -e "\033[1;33m$MSG_LOGS_EMPTY\033[0m"
        fi
        echo -e "\033[0;90m──────────────────────────────────────────────────\033[0m\n"
        exit 0
        ;;
        
    -h|--help)
        echo -e "\n\033[1;34m${ICON_INFO} $MSG_HELP_USAGE\033[0m"
        echo -e "\033[1m$MSG_HELP_OPT\033[0m"
        echo -e "  \033[36m•\033[0m $MSG_HELP_1"
        echo -e "  \033[36m•\033[0m $MSG_HELP_2"
        echo -e "  \033[36m•\033[0m $MSG_HELP_3"
        echo -e "  \033[36m•\033[0m $MSG_HELP_4"
        echo -e "  \033[36m•\033[0m $MSG_HELP_5\n"
        exit 0
        ;;
esac

CLEAR="\033[H\033[J"
echo -e "$CLEAR"

if [ -f "banner.txt" ]; then
    bash banner.txt
    echo -e ""
else
    echo -e "\033[1;33m${ICON_INFO} $MSG_BANNER_MISSING\033[0m"
fi

if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO_NAME="${PRETTY_NAME:-$NAME}"
else
    DISTRO_NAME="Unknown Linux"
fi

if command -v dnf &> /dev/null; then
    PKG_MANAGER="DNF (Fedora / RHEL)"
elif command -v apt &> /dev/null; then
    PKG_MANAGER="APT (Debian / Ubuntu)"
else
    PKG_MANAGER="Generic / Custom"
fi

if command -v timedatectl &> /dev/null; then
    CURRENT_TZ=$(timedatectl show --property=Timezone --value 2>/dev/null)
fi
CURRENT_TZ="${CURRENT_TZ:-UTC}"

echo -e "\033[1;34m${ICON_SYS}  $MSG_SYS_INFO\033[0m"
echo -e "\033[0;90m──────────────────────────────────────────────────\033[0m"
echo -e "  \033[1;37m$MSG_DISTRO   :\033[0m \033[1;36m$DISTRO_NAME\033[0m"
echo -e "  \033[1;37m$MSG_PKG_MGR  :\033[0m \033[1;32m$PKG_MANAGER\033[0m"
echo -e "  \033[1;37m$MSG_TIMEZONE :\033[0m \033[1;33m$CURRENT_TZ\033[0m"
echo -e "\033[0;90m──────────────────────────────────────────────────\033[0m"
echo -e ""

echo -e "\033[1;35m${ICON_ROCKET} $MSG_TITLE\033[0m"
echo -e "\033[0;90m──────────────────────────────────────────────────\033[0m"

if [ ! -f "dnpt.py" ]; then
    echo -e "\033[1;31m${ICON_ERROR} $MSG_ERR_DNPT\033[0m"
    echo -e "\033[1;33m${ICON_INFO} $MSG_ERR_DNPT_HINT\033[0m\n"
    exit 1
fi

echo -ne "\033[1;34m${ICON_PKG} $MSG_COPY\033[0m"
cp dnpt.py /usr/local/bin/apt
cp dnpt.py /usr/local/bin/dnpt
chmod +x /usr/local/bin/apt /usr/local/bin/dnpt
mkdir -p "$LOG_DIR"
sleep 0.3
echo -e " \033[1;32m[OK]\033[0m"

echo -e "\n\033[1;42;30m SUCCESS \033[0m \033[1;32m$MSG_INST_OK\033[0m"
echo -e "\033[1;36m${ICON_INFO} $MSG_READY\033[0m\n"