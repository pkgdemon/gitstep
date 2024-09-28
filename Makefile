# Makefile

# Check if running as root
check_root:
	@if [ $$(id -u) -ne 0 ]; then \
		echo "This Makefile must be run as root or with sudo."; \
		exit 1; \
	fi

# Set MAKE variable based on availability of gmake
ifeq ($(shell gmake -v >/dev/null 2>&1 && echo yes),yes)
	MAKE = gmake -j$(shell nproc)
else
	MAKE = make -j$(shell nproc)
endif

# Define the install target
install: check_root
	@if [ -d "/System" ]; then \
	  echo "System appears to be already installed."; \
	  exit 0; \
	else \
	WORKDIR=`pwd`; \
	CPUS=`nproc`; \
	export GNUSTEP_INSTALLATION_DOMAIN="SYSTEM"; \
	OS=`uname -s | tr '[:upper:]' '[:lower:]'`; \
	case "$$OS" in \
		"freebsd") \
			echo "Detected FreeBSD, running install-dependencies-freebsd script."; \
			$$WORKDIR/tools-scripts/install-dependencies-freebsd || exit 1;; \
		"linux") \
			echo "Detected Linux, running install-dependencies-linux script."; \
			$$WORKDIR/tools-scripts/install-dependencies-linux || exit 1;; \
		"netbsd") \
			echo "Detected NetBSD, running install-dependencies-netbsd script."; \
			$$WORKDIR/tools-scripts/install-dependencies-netbsd || exit 1;; \
		"openbsd") \
			echo "Detected OpenBSD, running install-dependencies-openbsd script."; \
			$$WORKDIR/tools-scripts/install-dependencies-openbsd || exit 1;; \
		*) \
			echo "Unsupported OS detected: $$OS. Exiting."; \
			exit 1;; \
	esac; \
	cd $$WORKDIR/tools-make && ./configure \
	  --prefix="/" \
      --with-layout=gnustep \
	  --with-config-file=/System/Library/Defaults/GNUstep.conf \
	  --with-library-combo=ng-gnu-gnu \
	&& $(MAKE) || exit 1 && $(MAKE) install; \
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