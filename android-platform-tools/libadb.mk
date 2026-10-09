-include ../trace-build-init.mk
############################################################################
# sources

LIBADB_SRC := \
  adb_unique_fd.cpp \
  adb_utils.cpp \
  fdevent/fdevent.cpp \
  sysdeps/env.cpp \
  sysdeps/errno.cpp \
  proto/adb_known_hosts.pb.cc \
  proto/app_processes.pb.cc \
  proto/key_type.pb.cc \
  proto/pairing.pb.cc \
  sysdeps_unix.cpp \
  sysdeps/posix/network.cpp \
  fdevent/fdevent_epoll.cpp \
  pairing_auth/aes_128_gcm.cpp \
  pairing_auth/pairing_auth.cpp \
  pairing_connection/pairing_connection.cpp \
  pairing_connection/pairing_server.cpp \
  crypto/key.cpp \
  crypto/rsa_2048_key.cpp \
  crypto/x509_generator.cpp \
  tls/adb_ca_list.cpp \
  tls/tls_connection.cpp \

LIBADB_LIBDIAGUSBSRC := diagnose_usb/diagnose_usb.cpp

LIBADB_SOURCES := \
  $(foreach s, $(LIBADB_SRC),           packages/modules/adb/$s) \
  $(foreach s, $(LIBADB_LIBDIAGUSBSRC), system/core/$s) \
  $(foreach s, $(LIBADB_GENSRC),        system/$s)

LIBADB_SOURCES_CPP := $(filter %.cpp,$(LIBADB_SOURCES))
LIBADB_OBJECTS_CPP := $(LIBADB_SOURCES_CPP:.cpp=.o)

LIBADB_SOURCES_CC  := $(filter %.cc,$(LIBADB_SOURCES))
LIBADB_OBJECTS_CC  := $(LIBADB_SOURCES_CC:.cc=.o)

############################################################################
# flags
LIBADB_CXXFLAGS := \
  -Wexit-time-destructors \
  -Wno-non-virtual-dtor \
  -Wno-unused-parameter \
  -Wno-missing-field-initializers \
  -Wvla

ifneq (,$(filter %-g++,$(CXX))$(filter %/g++,$(CXX))$(filter g++,$(CXX)))
  $(warning remove -Wexit-time-destructors for $(CXX) ($(shell which $(CXX))))
  LIBADB_CXXFLAGS := $(filter-out -Wexit-time-destructors,$(LIBADB_CXXFLAGS))
endif

# Note: proto headers and files are generated in the _build_
# tree and cannot be found via INCROOT:
LIBADB_CPPFLAGS := \
  -DPLATFORM_TOOLS_VERSION='"$(PLATFORM_TOOLS_VERSION)"' \
  -DADB_VERSION='"$(DEB_VERSION)"' \
  -DANDROID_BASE_UNIQUE_FD_DISABLE_IMPLICIT_CONVERSION=1 \
  -I$(INCROOT)/packages/modules/adb \
  -I$(INCROOT)/packages/modules/adb/crypto/include \
  -I$(INCROOT)/packages/modules/adb/pairing_auth/include \
  -I$(INCROOT)/packages/modules/adb/pairing_connection/include \
  -Ipackages/modules/adb/proto \
  -I$(INCROOT)/packages/modules/adb/tls/include \
  -I$(INCROOT)/system/core/diagnose_usb/include \
  -I$(INCROOT)/system/core/include \
  -I$(INCROOT)/system/core/libcrypto_utils/include \
  -I$(INCROOT)/system/core/libcutils/include \
  -I$(INCROOT)/system/libbase/include \
  -I/usr/include/android

############################################################################
# dependencies and build flags
o/system/libadb.a: CFLAGS   := $(BASE_CFLAGS)   $(LIBADB_CFLAGS)   $(EXTRA_CFLAGS)
o/system/libadb.a: CPPFLAGS := $(BASE_CPPFLAGS) $(LIBADB_CPPFLAGS) $(EXTRA_CPPFLAGS)
o/system/libadb.a: LDFLAGS  := $(BASE_LDFLAGS)  $(LIBADB_LDFLAGS)  $(EXTRA_LDFLAGS)
o/system/libadb.a: CXXFLAGS := $(BASE_CXXFLAGS) $(LIBADB_CXXFLAGS) $(EXTRA_CXXFLAGS)
o/system/libadb.a: $(LIBADB_OBJECTS_CC) $(LIBADB_OBJECTS_CPP)

OBJ_CC  += $(LIBADB_OBJECTS_CC)
OBJ_CPP += $(LIBADB_OBJECTS_CPP)
BUILT   += o/system/libadb.a
############################################################################
# clean
clean-libadb.a: OBJ := $(LIBADB_OBJECTS_CC) $(LIBADB_OBJECTS_CPP)
clean-libadb.a:
	@rm -vf $(OBJ)
	@rm -vf o/system/libadb.a
	@for d in $(dir $(filter %.pb.o,$(OBJ))); do rm -vf $$d/*.pb.*; done

clean: clean-libadb.a
############################################################################
-include ../trace-build-exit.mk
