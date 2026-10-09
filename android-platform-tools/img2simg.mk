-include ../trace-build-init.mk
############################################################################
# sources
I2S_SOURCES := system/core/libsparse/img2simg.cpp

I2S_SOURCES_CPP := $(filter %.cpp,$(I2S_SOURCES))
I2S_OBJECTS_CPP := $(I2S_SOURCES_CPP:.cpp=.o)

############################################################################
# flags
I2S_CPPFLAGS := -I$(INCROOT)/system/core/libsparse/include

I2S_LDFLAGS := \
  -Lo/system \
  -Wl,-rpath=/usr/lib/$(CARCH)/android \
  -lbase \
  -llog \
  -lpthread \
  -lsparse \
  -pie

############################################################################
# dependencies and build flags
I2S_SODEPS := $(patsubst %,o/system/lib%.so,base log sparse)

o/system/img2simg: CFLAGS   := $(BASE_CFLAGS)   $(I2S_CFLAGS)   $(EXTRA_CFLAGS)
o/system/img2simg: CPPFLAGS := $(BASE_CPPFLAGS) $(I2S_CPPFLAGS) $(EXTRA_CPPFLAGS)
o/system/img2simg: LDFLAGS  := $(BASE_LDFLAGS)  $(I2S_LDFLAGS)  $(EXTRA_LDFLAGS)
o/system/img2simg: CXXFLAGS := $(BASE_CXXFLAGS) $(I2S_CXXFLAGS) $(EXTRA_CXXFLAGS)
o/system/img2simg: | $(I2S_SODEPS)
o/system/img2simg: $(I2S_OBJECTS_CPP)

############################################################################
# built objects
OBJ_CPP    += $(I2S_OBJECTS_CPP)
BUILT      += o/system/img2simg

############################################################################
# clean
clean-img2simg: OBJ := $(I2S_OBJECTS_CPP)
clean-img2simg:
	@rm -vf $(OBJ)
	@rm -vf o/system/img2simg
	@for d in $(dir $(filter %.pb.o,$(OBJ))); do rm -vf $$d/*.pb.*; done

clean: clean-img2simg
############################################################################
# install
USR_BINS += o/system/img2simg

############################################################################
-include ../trace-build-exit.mk
