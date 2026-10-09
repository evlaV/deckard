include ../trace-build-init.mk
############################################################################
# sources
ETC1T_SOURCES := development/tools/etc1tool/etc1tool.cpp

ETC1T_SOURCES_CPP := $(filter %.cpp,$(ETC1T_SOURCES))
ETC1T_OBJECTS_CPP := $(ETC1T_SOURCES_CPP:.cpp=.o)

############################################################################
# flags
ETC1T_CPPFLAGS := \
  -I/usr/include/android \
  -I$(INCROOT)/development/include \
  -I$(INCROOT)/frameworks/native/opengl/include

ETC1T_LDFLAGS := -lpng -pie
ETC1T_STATIC_LIBS := o/frameworks/libETC1.a

############################################################################
# dependencies and build flags
o/development/etc1tool: CFLAGS   := $(BASE_CFLAGS)   $(ETC1T_CFLAGS)   $(EXTRA_CFLAGS)
o/development/etc1tool: CPPFLAGS := $(BASE_CPPFLAGS) $(ETC1T_CPPFLAGS) $(EXTRA_CPPFLAGS)
o/development/etc1tool: LDFLAGS  := $(BASE_LDFLAGS)  $(ETC1T_LDFLAGS)  $(EXTRA_LDFLAGS)
o/development/etc1tool: CXXFLAGS := $(BASE_CXXFLAGS) $(ETC1T_CXXFLAGS) $(EXTRA_CXXFLAGS)
o/development/etc1tool: $(ETC1T_OBJECTS_CPP) $(ETC1T_STATIC_LIBS)

############################################################################
# built objects
OBJ_CPP += $(ETC1T_OBJECTS_CPP)
BUILT   += o/development/etc1tool

############################################################################
# clean
clean-etc1tool: OBJ := $(ETC1T_OBJECTS_CPP)
clean-etc1tool:
	@rm -vf $(OBJ)
	@rm -vf o/development/etc1tool
	@for d in $(dir $(filter %.pb.o,$(OBJ))); do rm -vf $$d/*.pb.*; done

clean: clean-etc1tool

############################################################################
# install
TOOLS += o/development/etc1tool

############################################################################
-include ../trace-build-exit.mk

