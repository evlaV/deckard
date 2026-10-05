-include ../trace-build-init.mk
############################################################################
# sources
A2S_SOURCES := system/core/libsparse/append2simg.cpp

A2S_SOURCES_CPP := $(filter %.cpp,$(A2S_SOURCES))
A2S_OBJECTS_CPP := $(A2S_SOURCES_CPP:.cpp=.o)

############################################################################
# flags
A2S_CPPFLAGS := -I$(INCROOT)/system/core/libsparse/include

A2S_LDFLAGS := \
  -Lo/system \
  -Wl,-rpath=/usr/lib/$(CARCH)/android \
  -lbase \
  -llog \
  -lpthread \
  -lsparse \
  -pie

############################################################################
# dependencies and build flags
o/system/append2simg: CFLAGS   := $(BASE_CFLAGS)   $(A2S_CFLAGS)   $(EXTRA_CFLAGS)
o/system/append2simg: CPPFLAGS := $(BASE_CPPFLAGS) $(A2S_CPPFLAGS) $(EXTRA_CPPFLAGS)
o/system/append2simg: LDFLAGS  := $(BASE_LDFLAGS)  $(A2S_LDFLAGS)  $(EXTRA_LDFLAGS)
o/system/append2simg: CXXFLAGS := $(BASE_CXXFLAGS) $(A2S_CXXFLAGS) $(EXTRA_CXXFLAGS)
o/system/append2simg: | o/system/libbase.so o/system/libsparse.so o/system/liblog.so
o/system/append2simg: $(A2S_OBJECTS_CPP)

############################################################################
# built objects
OBJ_CPP    += $(A2S_OBJECTS_CPP)
BUILT      += o/system/append2simg

############################################################################
# clean
clean-append2simg: OBJ := $(A2S_OBJECTS_CPP)
clean-append2simg:
	@rm -vf $(OBJ)
	@rm -vf o/system/append2simg
	@for d in $(dir $(filter %.pb.o,$(OBJ))); do rm -vf $$d/*.pb.*; done

clean: clean-append2simg

############################################################################
# install
USR_BINS += o/system/append2simg

############################################################################
-include ../trace-build-exit.mk
