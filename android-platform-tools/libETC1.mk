-include ../trace-build-init.mk
############################################################################
# sources
LETC1_SOURCES := frameworks/native/opengl/libs/ETC1/etc1.cpp

LETC1_SOURCES_CPP := $(filter %.cpp,$(LETC1_SOURCES))
LETC1_OBJECTS_CPP := $(LETC1_SOURCES_CPP:.cpp=.o)

############################################################################
# flags
LETC1_CPPFLAGS := \
  -I$(INCROOT)/frameworks/native/opengl/include

############################################################################
# dependencies and build flags
o/frameworks/libETC1.a: CFLAGS   := $(BASE_CFLAGS)   $(LETC1_CFLAGS)   $(EXTRA_CFLAGS)
o/frameworks/libETC1.a: CPPFLAGS := $(BASE_CPPFLAGS) $(LETC1_CPPFLAGS) $(EXTRA_CPPFLAGS)
o/frameworks/libETC1.a: LDFLAGS  := $(BASE_LDFLAGS)  $(LETC1_LDFLAGS)  $(EXTRA_LDFLAGS)
o/frameworks/libETC1.a: CXXFLAGS := $(BASE_CXXFLAGS) $(LETC1_CXXFLAGS) $(EXTRA_CXXFLAGS)
o/frameworks/libETC1.a: SO_MAJOR := $(LETC1_SO_MAJOR)
o/frameworks/libETC1.a: $(LETC1_OBJECTS_CPP)

OBJ_CPP += $(LETC1_OBJECTS_CPP)
BUILT   += o/frameworks/libETC1.a

############################################################################
# clean
clean-libETC1.a:
	@rm -vf $(LETC1_OBJECTS_CPP)
	@rm -vf o/frameworks/libETC1.a

clean: clean-libETC1.a

############################################################################
-include ../trace-build-exit.mk
