# Dnpt - APT to DNF Command Translation Utility

`dnpt` is a lightweight Python-based command-line wrapper designed to map Debian/Ubuntu `apt` commands directly to their Fedora/RHEL `dnf` equivalents. It allows system administrators and developers familiar with APT syntax to seamlessly operate in RPM-based Linux environments.

---

## Technical Overview

- **Command Mapping:** Transparently translates common APT subcommands (`install`, `update`, `upgrade`, `remove`, `search`, `autoremove`) to DNF counterparts.
- **Automated Setup:** Includes an `install.sh` script to verify dependencies, detect environment settings, and handle path deployment.
- **Localization:** Supports multi-language console output configuration (English / Spanish).
- **Audit Logging:** Tracks executed commands and system operations via `--logs` flag.

---

## Command Reference Table

| APT Source Command | Translated DNF Execution | Description |
| :--- | :--- | :--- |
| `dnpt update` | `dnf check-update` | Refresh local repository metadata |
| `dnpt upgrade` | `dnf upgrade` | Upgrade all installed packages |
| `dnpt install <package>` | `dnf install <package>` | Download and install target package |
| `dnpt remove <package>` | `dnf remove <package>` | Uninstall target package |
| `dnpt purge <package>` | `dnf remove <package>` | Remove package and configuration files |
| `dnpt search <query>` | `dnf search <query>` | Query repositories for matching packages |
| `dnpt autoremove` | `dnf autoremove` | Remove orphaned dependencies |

---

## Installation

1. Clone or download the source repository.
2. Grant execution permissions to the installation script:

```bash
chmod +x install.sh
```

3. Execute the installer with elevated privileges:

```bash
sudo ./install.sh
```

---

## Usage

Once installed, execute `dnpt` directly using standard APT command syntax:

```bash
# Update repository index
dnpt update

# Install software packages
dnpt install htop systemd-resolved

# Review command logs
dnpt --logs
```

---

## License

This project is released under the MIT License. Refer to the `LICENSE` file for details.
