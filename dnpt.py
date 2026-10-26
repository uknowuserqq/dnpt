#!/usr/bin/env python3
import sys
import subprocess
import os
from datetime import datetime

SYS_LANG = os.environ.get("LANG", "en")[:2]
VERSION = "1.1.0"
LOG_DIR = "/var/log/dnpt"
LOG_FILE = os.path.join(LOG_DIR, "dnpt.log")

if SYS_LANG == "es":
    MSG_USAGE = "\033[1;34m󰋼 Uso:\033[0m apt [comando] [paquetes...] o dnpt [--version|--logs]"
    MSG_CANCEL = "\n\033[1;33m󰓛 Operación cancelada por el usuario.\033[0m"
    MSG_ERROR = "\033[1;31m󰅚 Error al ejecutar Dnpt:\033[0m"
    MSG_LOGS_TITLE = "REGISTROS DE ACTIVIDAD (LOGS)"
    MSG_LOGS_EMPTY = f"No hay registros de actividad todavía en: {LOG_FILE}"
else:
    MSG_USAGE = "\033[1;34m󰋼 Usage:\033[0m apt [command] [packages...] or dnpt [--version|--logs]"
    MSG_CANCEL = "\n\033[1;33m󰓛 Operation cancelled by user.\033[0m"
    MSG_ERROR = "\033[1;31m󰅚 Error executing Dnpt:\033[0m"
    MSG_LOGS_TITLE = "ACTIVITY LOGS"
    MSG_LOGS_EMPTY = f"No activity logs found yet at: {LOG_FILE}"

COMMAND_MAP = {
    "update": "check-update",
    "upgrade": "upgrade",
    "full-upgrade": "upgrade --refresh",
    "install": "install",
    "remove": "remove",
    "purge": "remove",
    "autoremove": "autoremove",
    "search": "search",
    "show": "info",
    "clean": "clean all",
    "autoclean": "clean expire-cache"
}

def write_log(cmd_str):
    try:
        os.makedirs(LOG_DIR, exist_ok=True)
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        with open(LOG_FILE, "a") as f:
            f.write(f"[{timestamp}] User executed: {cmd_str}\n")
    except Exception:
        pass

def show_logs():
    print(f"\n\033[1;34m󰌽 {MSG_LOGS_TITLE}\033[0m")
    print("\033[0;90m──────────────────────────────────────────────────\033[0m")
    if os.path.exists(LOG_FILE):
        with open(LOG_FILE, "r") as f:
            print(f.read(), end="")
    else:
        print(f"\033[1;33m{MSG_LOGS_EMPTY}\033[0m")
    print("\033[0;90m──────────────────────────────────────────────────\033[0m\n")

def main():
    if len(sys.argv) < 2:
        print(f"\n{MSG_USAGE}\n")
        sys.exit(1)

    apt_cmd = sys.argv[1]
    args = sys.argv[2:]

    if apt_cmd == "--version":
        print(f"\n\033[1;36m󰏗 Dnpt (APT-to-DNF Wrapper) v{VERSION}\033[0m\n")
        sys.exit(0)

    if apt_cmd == "--logs":
        show_logs()
        sys.exit(0)

    full_cmd_str = " ".join(sys.argv)
    write_log(full_cmd_str)

    if apt_cmd == "update":
        dnf_args = ["sudo", "dnf", "makecache"]
    elif apt_cmd in COMMAND_MAP:
        translated_cmd = COMMAND_MAP[apt_cmd]
        dnf_args = ["sudo", "dnf"] + translated_cmd.split() + args
    else:
        dnf_args = ["sudo", "dnf", apt_cmd] + args

    try:
        result = subprocess.run(dnf_args)
        sys.exit(result.returncode)
    except KeyboardInterrupt:
        print(f"\n{MSG_CANCEL}")
        sys.exit(130)
    except Exception as e:
        print(f"\n{MSG_ERROR} {e}\n")
        sys.exit(1)

if __name__ == "__main__":
    main()