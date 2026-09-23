##===- projects/sample/tools/Makefile ----------------------*- Makefile -*-===##

#
# Relative path to the top of the source tree.
#
LEVEL=../../..

#
# List all of the subdirectories that we will compile.
#

TOOLNAME=costdriver
#
# LIBRARYNAME = LLVMCostDriver
# LOADABLE_MODULE = 1
USEDLIBS = costmodel.a

LDFLAGS += -L../../../lib/analyzer/CostModel

LIBS    += -lcostmodel

# LLVMLIBS = LLVMSupport.a
LINK_COMPONENTS = all

include $(LEVEL)/Makefile.common
