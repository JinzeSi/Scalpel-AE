##===- projects/sample/tools/Makefile ----------------------*- Makefile -*-===##

#
# Relative path to the top of the source tree.
#
LEVEL=../../..

#
# List all of the subdirectories that we will compile.
#

TOOLNAME=commonsdriver

USEDLIBS=commons.a

LDFLAGS += -L../../../lib/commons \

LIBS    += -lcommons \

LINK_COMPONENTS = all

include $(LEVEL)/Makefile.common
