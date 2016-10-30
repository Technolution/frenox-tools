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

INSTALLDIR 	:= /opt/edes/
RELEASE	   	:= $(shell git describe --always)
PREFIX		:= $(INSTALLDIR)/$(RELEASE)

ISA			:= RV32IMA
XLEN		:= 32


all: build/riscv-gcc-newlib build/riscv-gcc-linux


.PHONY: fesvr gcc-newlib gcc-linux isa-sim

fesvr: build/riscv-fesvr
gcc-newlib: build/riscv-gcc-newlib
gcc-linux: build/riscv-gcc-linux
isa-sim: build/riscv-isa-sim

build/riscv-gcc-newlib:
	mkdir -p $@
	cd $@ && ../../riscv-gnu-toolchain/configure --prefix=$(PREFIX) --disable-float --enable-atomic --with-xlen=$(XLEN) --with-arch=$(ISA)
	make
	
build/riscv-gcc-linux:
	mkdir -p $@
	cd $@ && ../../riscv-gnu-toolchain/configure --prefix=$(PREFIX) --disable-float --enable-atomic --with-xlen=$(XLEN) --with-arch=$(ISA)
	make linux

build/riscv-fesvr:
	mkdir -p $@
	cd $@ && ../../riscv-fesvr/configure --prefix=$(PREFIX)
	$(MAKE) -C build/riscv-fesvr/ install
	
build/riscv-isa-sim: build/riscv-fesvr 
	mkdir -p $@
	cd $@ && ../../riscv-isa-sim/configure --prefix=$(PREFIX) --with-fesvr=$(PREFIX) --with-isa=$(ISA) --enable-32bit
	make install
	


