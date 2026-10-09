-include ../trace-build-init.mk
############################################################################
# sources
LCUTILS_SOURCES := \
  system/core/libcutils/sockets.cpp \
  system/core/libcutils/socket_inaddr_any_server_unix.cpp \
  system/core/libcutils/socket_local_client_unix.cpp \
  system/core/libcutils/socket_local_server_unix.cpp \
  system/core/libcutils/socket_network_client_unix.cpp \
  system/core/libcutils/sockets_unix.cpp \
  system/core/libcutils/fs.cpp \
  system/core/libcutils/hashmap.cpp \
  system/core/libcutils/multiuser.cpp \
  system/core/libcutils/str_parms.cpp \
  system/core/libcutils/config_utils.cpp \
  system/core/libcutils/iosched_policy.cpp \
  system/core/libcutils/load_file.cpp \
  system/core/libcutils/native_handle.cpp \
  system/core/libcutils/properties.cpp \
  system/core/libcutils/record_stream.cpp \
  system/core/libcutils/strlcpy.c \
  system/core/libcutils/ashmem-host.cpp \
  system/core/libcutils/canned_fs_config.cpp \
  system/core/libcutils/fs_config.cpp \
  system/core/libcutils/trace-host.cpp

LCUTILS_SOURCES_CPP := $(filter %.cpp,$(LCUTILS_SOURCES))
LCUTILS_OBJECTS_CPP := $(LCUTILS_SOURCES_CPP:.cpp=.o)

LCUTILS_SOURCES_C   := $(filter %.c,$(LCUTILS_SOURCES))
LCUTILS_OBJECTS_C   := $(LCUTILS_SOURCES_C:.c=.o)

LCUTILS_SO_MAJOR    := 0

############################################################################
# flags
LCUTILS_CPPFLAGS += \
  -I$(INCROOT)/system/core/include \
  -I$(INCROOT)/system/core/libcutils/include \
  -I$(INCROOT)/system/libbase/include \
  -I$(INCROOT)/system/logging/liblog/include \

LCUTILS_LDFLAGS := \
  -Lo/system \
  -Wl,-rpath=/usr/lib/$(CARCH)/android \
  -Wl,-soname,libcutils.so.$(LCUTILS_SO_MAJOR) \
  -lbase \
  -llog \
  -lpthread \
  -shared

############################################################################
# dependencies and build flags
o/system/libcutils.so: CFLAGS   := $(BASE_CFLAGS)   $(LCUTILS_CFLAGS)   $(EXTRA_CFLAGS)
o/system/libcutils.so: CPPFLAGS := $(BASE_CPPFLAGS) $(LCUTILS_CPPFLAGS) $(EXTRA_CPPFLAGS)
o/system/libcutils.so: LDFLAGS  := $(BASE_LDFLAGS)  $(LCUTILS_LDFLAGS)  $(EXTRA_LDFLAGS)
o/system/libcutils.so: CXXFLAGS := $(BASE_CXXFLAGS) $(LCUTILS_CXXFLAGS) $(EXTRA_CXXFLAGS)
o/system/libcutils.so: SO_MAJOR := $(LCUTILS_SO_MAJOR)
o/system/libcutils.so: | o/system/libbase.so o/system/liblog.so
o/system/libcutils.so: $(LCUTILS_OBJECTS_C) $(LCUTILS_OBJECTS_CPP)

OBJ_C   += $(LCUTILS_OBJECTS_C)
OBJ_CPP += $(LCUTILS_OBJECTS_CPP)
BUILT   += o/system/libcutils.so

############################################################################
# clean
clean-libcutils.so:
	@rm -vf $(LCUTILS_OBJECTS_C) $(LCUTILS_OBJECTS_CPP)
	@rm -vf o/system/libcutils.so{,.$(LCUTILS_SO_MAJOR)}

clean: clean-libcutils.so

############################################################################
# install
INCLUDES  += $(INCROOT)/system/core/libcutils/include/cutils
LIBRARIES += o/system/libcutils.so
LIBRARIES += o/system/libcutils.so.$(LCUTILS_SO_MAJOR)

############################################################################
-include ../trace-build-exit.mk
