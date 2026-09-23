##===- projects/sample/tools/Makefile ----------------------*- Makefile -*-===##

#
# Relative path to the top of the source tree.
#
LEVEL=../../..

#
# List all of the subdirectories that we will compile.
#

TOOLNAME=decoderdriver

USEDLIBS=parser.a commons.a mappercore.a

#LLVMLIBS=LLVMSupport.a LLVMCore.a LLVMSupport.a LLVMCore.a LLVMBitReader.a LLVMAsmParser.a LLVMAnalysis.a LLVMTransformUtils.a LLVMScalarOpts.a LLVMTarget.a

LDFLAGS += -L../../../lib/mapper \
           -L../../../lib/commons \
		   -L../../../lib/parser/PatchIRDecoder

LIBS    += -lparser \
		   -lmappercore \
		   -lcommons

LINK_COMPONENTS = all

include $(LEVEL)/Makefile.common
