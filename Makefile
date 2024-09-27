# Makefile

# Check if running as root
check_root:
	@if [ $$(id -u) -ne 0 ]; then \
		echo "This Makefile must be run as root or with sudo."; \
		exit 1; \
	fi

# Define the install target
install: check_root
	@if [ -d "/System" ]; then \
	  echo "System appears to be already installed."; \
	  exit 0; \
	else \
	WORKDIR=`pwd`; \
	CPUS=`nproc`; \
	export GNUSTEP_INSTALLATION_DOMAIN="SYSTEM"; \
	cd $$WORKDIR/tools-make && ./configure \
	  --prefix="/" \
      --with-layout=gnustep \
	  --with-config-file=/System/Library/Defaults/GNUstep.conf \
	  --with-library-combo=ng-gnu-gnu \
	&& gmake || exit 1 && gmake install; \
	fi;

# Define the uninstall target
uninstall: check_root
	@removed=""; \
	if [ -d "/System" ]; then \
	  rm -rf /System; \
	  removed="/System"; \
	  echo "Removed /System"; \
	fi; \
	if [ -n "$$removed" ]; then \
	  return 0; \
	else \
	  echo "System appears to be already uninstalled.  Nothing was removed"; \
	fi
