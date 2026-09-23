##===- projects/sample/tools/Makefile ----------------------*- Makefile -*-===##

#
# Relative path to the top of the source tree.
#
LEVEL=../..

#
# List all of the subdirectories that we will compile.
#

TOOLNAME=perfscope

USEDLIBS=parser.a riskeval.a costmodel.a diffengine.a mappercore.a slicer.a llvmslicer.a callgraph.a mods.a points.a dependence.a commons.a language.a

#USEDLIBS=parser.a mappercore.a riskeval.a costmodel.a diffengine.a dependence.a commons.a 

# LLVMLIBS=LLVMSupport.a LLVMCore.a LLVMSupport.a LLVMCore.a LLVMBitReader.a LLVMAsmParser.a \
				LLVMAnalysis.a LLVMTransformUtils.a LLVMScalarOpts.a LLVMTarget.a

LDFLAGS += -L../../lib/slicer \
           -L../../lib/mapper \
           -L../../lib/analyzer/CostModel \
		   -L../../lib/analyzer/DiffEngine \
           -L../../lib/analyzer/RiskEvaluator \
           -L../../lib/commons \
		   -L../../lib/dependence \
		   -L../../lib/graph \
		   -L../../lib/parser/PatchIRDecoder \
		   -L../../third-party/LLVMSlicer/Callgraph \
		   -L../../third-party/LLVMSlicer/Slicing \
		   -L../../third-party/LLVMSlicer/Modifies \
		   -L../../third-party/LLVMSlicer/PointsTo \
		   -L../../third-party/LLVMSlicer/Languages \
		   -L../../third-party/patch

LIBS    += -lparser \
		   -lriskeval \
		   -lcostmodel \
		   -ldiffengine \
		   -lmappercore \
		   -lslicer \
		   -lllvmslicer \
		   -lcallgraph \
		   -lmods \
		   -lpoints \
		   -ldependence \
		   -lcommons \
		   -lgraph \
		   -llanguage \
		   -lgnulib \

LINK_COMPONENTS = all

include $(LEVEL)/Makefile.common
