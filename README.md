
# GitStep

## Overview
GitStep is a multi-platform installer designed to set up GNUstep with the GNUstep layout using the `/usr/GNUstep` prefix. It simplifies the process of installing GNUstep across various operating systems, ensuring a consistent environment setup.

## Prerequisites
- **Git**: Ensure `git` is installed on your system.
- **Administrative Privileges**: You'll need `sudo` access for installation.
- **Supported Platforms**: FreeBSD, Linux, NetBSD, and OpenBSD.

## Installation

1. **Clone the repository with submodules:**

   ```bash
   git clone https://github.com/pkgdemon/gitstep.git --recurse-submodules
   ```

2. **Navigate to the GitStep directory and install dependencies:**

   ```bash
   cd gitstep
   sudo ./bootstrap.sh
   ```

   This step will automatically detect your operating system and install all required dependencies.

3. **Install GNUstep using make:**

   ```bash
   sudo make install
   ```

   This command installs GNUstep using the GNUstep layout with the `/` prefix, as intended by GitStep.

## Uninstallation

To remove GNUstep installed by GitStep, run:
```bash
sudo make uninstall
```

## Cleanup

To clean up temporary files and remove the `system.txz` tar archive, run:
```bash
sudo make clean
```