# GitStep

## Installation

1. Clone the repository with submodules:

```
git clone https://github.com/pkgdemon/gitstep.git --recurse-submodules
```

2. Enter repository and install using make:
```
cd gitstep && sudo make install
```

## Uninstallation

```
sudo make uninstall
```

## Cleanup

This command will remove the system.txz tar archive:

```
sudo make clean
```