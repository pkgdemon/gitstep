#!/bin/sh

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root or with sudo."
    exit 1
fi

# Determine the current working directory
WORKDIR=$(pwd)

# Detect the operating system
OS=$(uname -s | tr '[:upper:]' '[:lower:]')

# Execute the appropriate script based on the detected OS
case "$OS" in
    "freebsd")
        echo "Detected FreeBSD, running install-dependencies-freebsd script."
        "$WORKDIR/tools-scripts/install-dependencies-freebsd" || exit 1
        ;;
    "linux")
        echo "Detected Linux, running install-dependencies-linux script."
        "$WORKDIR/tools-scripts/install-dependencies-linux" || exit 1
        ;;
    "netbsd")
        echo "Detected NetBSD, running install-dependencies-netbsd script."
        "$WORKDIR/tools-scripts/install-dependencies-netbsd" || exit 1
        ;;
    "openbsd")
        echo "Detected OpenBSD, running install-dependencies-openbsd script."
        "$WORKDIR/tools-scripts/install-dependencies-openbsd" || exit 1
        ;;
    *)
        echo "Unsupported OS detected: $OS. Exiting."
        exit 1
        ;;
esac

echo "Bootstrap process completed successfully."