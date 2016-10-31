###############################################################################
##
## (C) COPYRIGHT 2006-2016 TECHNOLUTION BV, GOUDA NL
## | =======          I                   ==          I    =
## |    I             I                    I          I
## |    I   ===   === I ===  I ===   ===   I  I    I ====  I   ===  I ===
## |    I  /   \ I    I/   I I/   I I   I  I  I    I  I    I  I   I I/   I
## |    I  ===== I    I    I I    I I   I  I  I    I  I    I  I   I I    I
## |    I  \     I    I    I I    I I   I  I  I   /I  \    I  I   I I    I
## |    I   ===   === I    I I    I  ===  ===  === I   ==  I   ===  I    I
## |                 +---------------------------------------------------+
## +----+            |  +++++++++++++++++++++++++++++++++++++++++++++++++|
##      |            |             ++++++++++++++++++++++++++++++++++++++|
##      +------------+                          +++++++++++++++++++++++++|
##                                                         ++++++++++++++|
##              A U T O M A T I O N     T E C H N O L O G Y         +++++|
##
###############################################################################
## This is a meta makefile to build all toolchain components for the frenox
## core
###############################################################################

INSTALLDIR 	:= /opt/edes/toolchains/
RELEASE	   	:= $(shell git describe --always)
PREFIX		:= $(abspath $(INSTALLDIR)/gcc-riscv-unknown-rv32ima-$(RELEASE)/)

ISA		:= RV32IMA
XLEN		:= 32


###############################################################################
## phony rules
###############################################################################
.PHONY: all fesvr gcc-newlib gcc-linux isa-sim tag sub-update show-prefix push-tag

all: fesvr gcc-newlib gcc-linux isa-sim
fesvr: build/riscv-fesvr/done
gcc-newlib: build/riscv-gcc-newlib/done
gcc-linux: build/riscv-gcc-linux/done
isa-sim: build/riscv-isa-sim/done
sub-update: build/sub-update

show-prefix:
	@echo "install prefix := $(PREFIX)"

push-tag:
	git push --follow-tags

###############################################################################
## build rules
###############################################################################

build/sub-update:
	mkdir -p $(@D)	
	git submodule update --init --recursive
	touch $@

build/riscv-gcc-newlib/done: build/sub-update
	mkdir -p $(@D)
	cd $(@D) && ../../riscv-gnu-toolchain/configure --prefix=$(PREFIX) --disable-float --enable-atomic --with-xlen=$(XLEN) --with-arch=$(ISA)
	make -C $(@D)
	touch $@

build/riscv-gcc-linux/done: build/sub-update
	mkdir -p $(@D)
	cd $(@D) && ../../riscv-gnu-toolchain/configure --prefix=$(PREFIX) --disable-float --enable-atomic --with-xlen=$(XLEN) --with-arch=$(ISA)
	make -C $(@D) linux
	touch $@

build/riscv-fesvr/done: build/sub-update
	mkdir -p $(@D)
	cd $(@D) && ../../riscv-fesvr/configure --prefix=$(PREFIX)
	$(MAKE) -C $(@D) install
	touch $@

build/riscv-isa-sim/done: build/riscv-fesvr/done build/sub-update
	mkdir -p $(@D)
	cd $(@D) && ../../riscv-isa-sim/configure --prefix=$(PREFIX) --with-fesvr=$(PREFIX) --with-isa=$(ISA)
	make -C $(@D) install
	touch $@

clean:
	rm -rf build/

###############################################################################
## rules used to export repos
###############################################################################
## by calling
##    make repo-export
## an build/export directory is created containing all git archive used by this
## archive and its submodules. This can be used to 'archive' this repos and
## its dependencies easiely
###############################################################################
REPO_URLS = $(shell git submodule foreach --recursive 'git config --get remote.origin.url' | grep http)
REPO_URLS += $(shell git config --get remote.origin.url)

show-repos: build/sub-update
	@echo $(REPOS)

build/export/: build/
	mkdir -p $@

define repo_export_template
build/export/$(1).git: build/export/
	cd build/export && git clone --bare $(2)

REPOS += build/export/$(1).git
endef

$(foreach url, $(REPO_URLS), $(eval $(call repo_export_template,$(strip $(basename $(notdir $(url)))), $(url))))

repo-export: $(REPOS) build/sub-update
