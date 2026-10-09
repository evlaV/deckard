-include ../trace-build-init.mk
############################################################################
# sources
# packages/modules/adb/Android.bp
ADBD_SRCS := \
  adb.cpp \
  adb_io.cpp \
  adb_listeners.cpp \
  adb_trace.cpp \
  services.cpp \
  sockets.cpp \
  socket_spec.cpp \
  transport.cpp \
  transport_fd.cpp \
  types.cpp \
  daemon/adb_wifi.cpp \
  daemon/auth.cpp \
  daemon/jdwp_service.cpp \
  daemon/logging.cpp \
  daemon/main.cpp \
  daemon/transport_local.cpp \
  daemon/usb.cpp \
  daemon/usb_ffs.cpp

LIBADBD_adbconnection_server_SRC_FILES := \
  libs/adbconnection/adbconnection_server.cpp

LIBADBD_services_SRC_FILES := \
  daemon/file_sync_service.cpp \
  daemon/services.cpp \
  daemon/restart_service.cpp \
  daemon/shell_service.cpp \
  shell_service_protocol.cpp

LIBADBD_fs_SRC_FILES := \
  libs/libadbd_fs/adbd_fs.cpp \

LIBDIAGNOSE_USB_SRC_FILES := diagnose_usb/diagnose_usb.cpp
LIBASYNCIO_SRC_FILES := libasyncio/AsyncIO.cpp

LIBADBD_AUTH_SRC_FILES = libs/adbd_auth/adbd_auth.cpp

ADBD_SRC_FILES := \
  $(ADBD_SRCS) \
  $(LIBADBD_adbconnection_server_SRC_FILES) \
  $(LIBADBD_services_SRC_FILES) \
  $(LIBADBD_fs_SRC_FILES) \

ADBD_SOURCES := \
  $(foreach s, $(ADBD_SRC_FILES), packages/modules/adb/$s) \
  $(foreach s, $(LIBDIAGNOSE_USB_SRC_FILES), system/core/$s) \
  $(foreach s, $(LIBASYNCIO_SRC_FILES), system/core/$s) \
  $(foreach s, $(LIBADBD_AUTH_SRC_FILES), frameworks/native/$s)

ADBD_SOURCES_CPP := $(filter %.cpp,$(ADBD_SOURCES))
ADBD_OBJECTS_CPP := $(ADBD_SOURCES_CPP:.cpp=.adbd.o)

ADBD_STATIC_LIBS := o/system/libadb.a o/system/libcrypto_utils.a

############################################################################
# flags
ADBD_CXXFLAGS := -Wno-narrowing

# Note: proto headers and files are generated in the _build_
# tree and cannot be found via INCROOT:
ADBD_CPPFLAGS := \
  -D_GNU_SOURCE \
  -DPLATFORM_TOOLS_VERSION='"$(PLATFORM_TOOLS_VERSION)"' \
  -DADB_HOST=0 \
  -DADB_VERSION='"$(PLATFORM_TOOLS_VERSION)"' \
  -DANDROID_BASE_UNIQUE_FD_DISABLE_IMPLICIT_CONVERSION=1 \
  -DPAGE_SIZE=4096 \
  -I$(INCROOT)/frameworks/native/libs/adbd_auth/include/ \
  -I$(INCROOT)/packages/modules/adb \
  -I$(INCROOT)/packages/modules/adb/crypto/include \
  -I$(INCROOT)/packages/modules/adb/libs/libadbd_fs/include \
  -I$(INCROOT)/packages/modules/adb/libs/adbconnection/include \
  -Ipackages/modules/adb/proto \
  -I$(INCROOT)/packages/modules/adb/tls/include \
  -I$(INCROOT)/system/core/diagnose_usb/include \
  -I$(INCROOT)/system/core/include \
  -I$(INCROOT)/system/core/libasyncio/include \
  -I$(INCROOT)/system/core/libcrypto_utils/include \
  -I$(INCROOT)/system/core/libcutils/include \
  -I$(INCROOT)/system/libbase/include \
  -I$(INCROOT)/system/logging/liblog/include \
  -I/usr/include/android

ADBD_LDFLAGS := \
  -Lo/system \
  -L/usr/lib/$(CARCH)/android \
  -Wl,-rpath=/usr/lib/$(CARCH)/android \
  -lbase \
  -lbrotlidec \
  -lbrotlienc \
  -lcrypto \
  -lcutils \
  -llog \
  -llz4 \
  -lprotobuf \
  -lresolv \
  -lssl \
  -lsystemd \
  -lzstd \
  -pie

############################################################################
# dependencies and build flags
ADBD_SODEPS := $(patsubst %,o/system/lib%.so,base cutils log)

o/system/adbd: CFLAGS   := $(BASE_CFLAGS)   $(ADBD_CFLAGS)   $(EXTRA_CFLAGS)
o/system/adbd: CPPFLAGS := $(BASE_CPPFLAGS) $(ADBD_CPPFLAGS) $(EXTRA_CPPFLAGS)
o/system/adbd: LDFLAGS  := $(BASE_LDFLAGS)  $(ADBD_LDFLAGS)  $(EXTRA_LDFLAGS)
o/system/adbd: CXXFLAGS := $(BASE_CXXFLAGS) $(ADBD_CXXFLAGS) $(EXTRA_CXXFLAGS)
o/system/adbd: | $(ADBD_SODEPS)
o/system/adbd: $(ADBD_OBJECTS_CPP) $(ADBD_STATIC_LIBS)

############################################################################
# built objects
BUILT += o/system/adbd

$(ADBD_OBJECTS_CPP): %.adbd.o: %.cpp
	@mkdir -p $(@D)
	$(V_CXX)$(CXX) -c -o $@ $< $(CXXFLAGS) $(CPPFLAGS)

############################################################################
# clean
clean-adbd: OBJ := $(ADBD_OBJECTS_CPP)
clean-adbd:
	@rm -vf $(OBJ)
	@rm -vf o/system/adbd
	@for d in $(dir $(filter %.pb.o,$(OBJ))); do rm -vf $$d/*.pb.*; done

clean: clean-adbd

############################################################################
# install
TOOLS     += o/system/adbd
MISC_INST += ../adbd.service::usr/lib/systemd/system/adbd.service
MISC_INST += ../adbd-pre.service::usr/lib/systemd/system/adbd-pre.service
MISC_INST += ../adbd-post.service::usr/lib/systemd/system/adbd-post.service
MISC_INST += ../usb-gadget-adbd-restart.conf::usr/lib/systemd/system/usb-gadget.service.d/usb-gadget-adbd-restart.conf
MISC_INST += ../dev-usb-ffs-adb.mount::usr/lib/systemd/system/dev-usb\\x2dffs-adb.mount
MISC_INST += ../adbd.modules-load::usr/lib/modules-load.d/adbd.conf

############################################################################
EXTRA_OBJ_CPP := $(ADBD_OBJECTS_CPP)
-include ../trace-build-exit.mk
