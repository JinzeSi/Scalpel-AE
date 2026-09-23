##===- projects/sample/lib/sample/Makefile -----------------*- Makefile -*-===##

#
# Indicate where we are relative to the top of the source tree.
#
LEVEL=../../..

TOOLNAME = patch-c

USEDLIBS = gnulib.a

LDFLAGS += -L$(LEVEL)/third-party/patch
LIBS    += -lgnulib

#
# Include Makefile.common so we know what to do.
#
include $(LEVEL)/Makefile.common
