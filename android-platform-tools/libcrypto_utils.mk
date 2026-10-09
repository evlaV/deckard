-include ../trace-build-init.mk
############################################################################
# sources
LCU_SOURCES := system/core/libcrypto_utils/android_pubkey.cpp

LCU_SOURCES_CPP := $(filter %.cpp,$(LCU_SOURCES))
LCU_OBJECTS_CPP := $(LCU_SOURCES_CPP:.cpp=.o)

LCU_SOURCES_CC  := $(filter %.cc,$(LCU_SOURCES))
LCU_OBJECTS_CC  := $(LCU_SOURCES_CC:.cc=.o)

############################################################################
# flags
LCU_CPPFLAGS := \
  -I$(INCROOT)/system/core/include \
  -I$(INCROOT)/system/core/libcrypto_utils/include \
  -I/usr/include/android

############################################################################
# dependencies and build flags
o/system/libcrypto_utils.a: CFLAGS   := $(BASE_CFLAGS)   $(LCU_CFLAGS)   $(EXTRA_CFLAGS)
o/system/libcrypto_utils.a: CPPFLAGS := $(BASE_CPPFLAGS) $(LCU_CPPFLAGS) $(EXTRA_CPPFLAGS)
o/system/libcrypto_utils.a: LDFLAGS  := $(BASE_LDFLAGS)  $(LCU_LDFLAGS)  $(EXTRA_LDFLAGS)
o/system/libcrypto_utils.a: CXXFLAGS := $(BASE_CXXFLAGS) $(LCU_CXXFLAGS) $(EXTRA_CXXFLAGS)
o/system/libcrypto_utils.a: $(LCU_OBJECTS_CC) $(LCU_OBJECTS_CPP)

OBJ_CC  += $(LCU_OBJECTS_CC)
OBJ_CPP += $(LCU_OBJECTS_CPP)
BUILT   += o/system/libcrypto_utils.a

############################################################################
# clean
clean-libcrypto_utils.a:
	@rm -vf $(LCU_OBJECTS_CC) $(LCU_OBJECTS_CPP)
	@rm -vf o/system/libcrypto_utils.a

clean: clean-libcrypto_utils.a

############################################################################
-include ../trace-build-exit.mk
