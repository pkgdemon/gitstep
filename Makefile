# Check if running as root
check_root:
	@if [ $$(id -u) -ne 0 ]; then \
		echo "This Makefile must be run as root or with sudo."; \
		exit 1; \
	fi

# Define the install target
install: check_root
	@if [ -d "/usr/GNUstep" ]; then \
	  echo "GNUstep is already installed"; \
	  exit 0; \
	else \
	WORKDIR=`pwd`; \
	CPUS=`nproc`; \
	OS=`uname -s | tr '[:upper:]' '[:lower:]'`; \
	case "$$(command -v gmake 2>/dev/null)" in \
		*gmake) \
			MAKE="gmake -j$$CPUS"; \
			;; \
		*) \
			MAKE="make -j$$CPUS"; \
			;; \
	esac; \
	export GNUSTEP_INSTALLATION_DOMAIN="SYSTEM"; \
	cd $$WORKDIR/tools-make && ./configure \
      --with-layout=gnustep \
	  --with-library-combo=ng-gnu-gnu \
	&& eval "$$MAKE" || exit 1 && eval "$$MAKE install"; \
	. /usr/GNUstep/System/Library/Makefiles/GNUstep.sh; \
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
	cd $$WORKDIR/apps-easydiff && eval "$$MAKE" && eval "$$MAKE" install; \
	cd $$WORKDIR/apps-gorm && eval "$$MAKE" && eval "$$MAKE" install; \
	cd $$WORKDIR/apps-projectcenter && eval "$$MAKE" && eval "$$MAKE" install; \
	mkdir -p /etc/profile.d >/dev/null 2>&1 || true; \
	ln -sf /usr/GNUstep/System/Library/Makefiles/GNUstep.sh /etc/profile.d/GNUstep.sh >/dev/null 2>&1 || true; \
	echo "Symlinked /usr/GNUstep/System/Library/Makefiles/GNUstep.sh to /etc/profile.d/GNUstep.sh"; \
	fi;

# Define the uninstall target
uninstall: check_root
	@removed=""; \
	if [ -L "/etc/profile.d/GNUstep.sh" ]; then \
	  rm -f /etc/profile.d/GNUstep.sh; \
	  removed="$$removed /etc/profile.d/GNUstep.sh"; \
	  echo "Removed symlink /etc/profile.d/GNUstep.sh"; \
	fi; \
	if [ -d "/usr/GNUstep" ]; then \
	  rm -rf /usr/GNUstep; \
	  removed="/usr/GNUstep"; \
	  echo "Removed /usr/GNUstep"; \
	fi; \
	if [ -f "/etc/GNUstep/GNUstep.conf" ]; then \
	  rm -f /etc/GNUstep/GNUstep.conf; \
	  removed="$$removed /etc/GNUstep/GNUstep.conf"; \
	  echo "Removed /etc/GNUstep/GNUstep.conf"; \
	fi; \
	if [ -n "$$removed" ]; then \
	  exit 0; \
	else \
	  echo "No items needed to be removed."; \
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
	@if [ -d "libobjc2/Build" ]; then \
		echo "Removing libobjc2/Build..."; \
		sudo rm -rf libobjc2/Build; \
	fi
	@echo "Clean complete."