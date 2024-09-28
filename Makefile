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
	OS=`uname -s | tr '[:upper:]' '[:lower:]'`; \
	# Detect the make command \
	if command -v gmake >/dev/null 2>&1; then \
		MAKE="gmake -j$$CPUS"; \
	else \
		MAKE="make -j$$CPUS"; \
	fi; \
	export GNUSTEP_INSTALLATION_DOMAIN="SYSTEM"; \
	cd $$WORKDIR/tools-make && ./configure \
	  --prefix="/" \
      --with-layout=gnustep \
	  --with-config-file=/System/Library/Defaults/GNUstep.conf \
	  --with-library-combo=ng-gnu-gnu \
	&& eval "$$MAKE" || exit 1 && eval "$$MAKE install"; \
	. /System/Library/Makefiles/GNUstep.sh; \
	mkdir -p $$WORKDIR/libobjc2/Build; \
	cd $$WORKDIR/libobjc2/Build && pwd && ls && cmake .. \
	  -DGNUSTEP_INSTALL_TYPE=SYSTEM \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_C_COMPILER=clang \
	  -DCMAKE_CXX_COMPILER=clang++ \
	&& eval "$$MAKE" || exit 1 \
	&& eval "$$MAKE" install; \
	cd $$WORKDIR/libs-base && ./configure --with-installation-domain=SYSTEM && eval "$$MAKE" || exit 1 && eval "$$MAKE" install; \
	cd $$WORKDIR/libs-gui && ./configure && eval "$$MAKE" || exit 1 || exit 1 && eval "$$MAKE" install; \
	cd $$WORKDIR/libs-back && export fonts=no && ./configure && eval "$$MAKE" || exit 1 && eval "$$MAKE" install; \
	cd $$WORKDIR/apps-gworkspace && ./configure && eval "$$MAKE" && eval "$$MAKE" install; \
	cd $$WORKDIR/apps-systempreferences && eval "$$MAKE" && eval "$$MAKE" install; \
	unset GNUSTEP_INSTALLATION_DOMAIN; \
	cd $$WORKDIR/gap && eval "$$MAKE" && eval "$$MAKE" install; \
	fi;

# Define the uninstall target
uninstall: check_root
	@removed=""; \
	if [ -d "/System" ]; then \
	  rm -rf /System; \
	  removed="/System"; \
	  echo "Removed /System"; \
	fi; \
	if [ -d "/Local" ]; then \
	  rm -rf /Local; \
	  removed="$$removed /Local"; \
	  echo "Removed /Local"; \
	fi; \
	if [ -n "$$removed" ]; then \
	  echo "Directories removed: $$removed"; \
	  exit 0; \
	else \
	  echo "No directories were removed. It appears that nothing was installed yet."; \
	fi

# Define the clean target
clean: check_root
	@echo "Cleaning main project..."
	@WORKDIR=`pwd`; \
	if [ -d "$$WORKDIR" ]; then \
		echo "Cleaning the main project directory"; \
		git clean -fdx; \
		git reset --hard; \
	fi
	@echo "Cleaning git submodules..."
	@git submodule foreach --recursive 'echo "Cleaning $$name"; git clean -fdx; git reset --hard'
	@echo "Clean complete."