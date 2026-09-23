##===- lib/Transforms/MDMap/Makefile -----------------------*- Makefile -*-===##

LEVEL = ../../..
LIBRARYNAME = LLVMMatchTest
LOADABLE_MODULE = 1
USEDLIBS = commons.a parser.a mappercore.a

LDFLAGS += -L../../../lib/mapper \
           -L../../../lib/commons \
		   -L../../../lib/parser/PatchIRDecoder

LIBS    += -lparser \
		   -lmappercore \
		   -lcommons


include $(LEVEL)/Makefile.common

