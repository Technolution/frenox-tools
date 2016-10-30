# Frenox tools meta archive
Contains all required steps and submodule archives to build the tools for frenox (a RV32IMA core).

Steps to build:

1. Check if destionation dir is oke by checking `INSTALLDIR` in  `Makefile`. Note that the prefix
   that is used to install the tools contains an aditional prefix (containing a description of this git
   checkout).

2. Check if current user has the right permisions to write/copy files in `INSTALLDIR`.

3. Run make

> make

4. Update tl_env config with the new tool install. Use `make show-prefix` to see install dir
