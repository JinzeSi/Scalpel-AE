##===- projects/sample/tools/Makefile ----------------------*- Makefile -*-===##

#
# Relative path to the top of the source tree.
#
LEVEL=../../..

#
# List all of the subdirectories that we will compile.
#

TOOLNAME=riskevaldriver
#
# LIBRARYNAME = LLVMCostDriver
# LOADABLE_MODULE = 1
USEDLIBS = riskeval.a costmodel.a llvmslicer.a callgraph.a mods.a points.a dependence.a language.a mappercore.a slicer.a dependence.a commons.a 

LDFLAGS += -L../../../lib/slicer \
           -L../../../lib/mapper \
		   -L../../../lib/analyzer/CostModel \
           -L../../../lib/analyzer/RiskEvaluator \
           -L../../../lib/commons \
		   -L../../../lib/dependence \
		   -L../../../lib/graph \
		   -L../../../lib/parser/PatchIRDecoder \
		   -L../../../third-party/LLVMSlicer/Callgraph \
		   -L../../../third-party/LLVMSlicer/Slicing \
		   -L../../../third-party/LLVMSlicer/Modifies \
		   -L../../../third-party/LLVMSlicer/PointsTo \
		   -L../../../third-party/LLVMSlicer/Languages \
		   -L../../../third-party/patch

LIBS    += -lriskeval \
		   -lcostmodel \
		   -lllvmslicer \
		   -lcallgraph \
		   -lmods \
		   -lpoints \
		   -ldependence \
		   -lmappercore \
		   -lcommons \
		   -lgraph \
		   -llanguage \
		   -lslicer \
		   -lgnulib \


# LLVMLIBS = LLVMSupport.a
LINK_COMPONENTS = all

include $(LEVEL)/Makefile.common
