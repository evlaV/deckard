-include ../trace-build-init.mk
############################################################################
# sources
ADB_SRC := \
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
  client/adb_client.cpp \
  client/bugreport.cpp \
  client/commandline.cpp \
  client/file_sync_client.cpp \
  client/main.cpp \
  client/console.cpp \
  client/adb_install.cpp \
  client/line_printer.cpp \
  client/fastdeploycallbacks.cpp \
  client/incremental.cpp \
  client/incremental_server.cpp \
  client/incremental_utils.cpp \
  shell_service_protocol.cpp \
  fastdeploy/proto/ApkEntry.pb.cc \
  client/auth.cpp \
  client/adb_wifi.cpp \
  client/usb_libusb.cpp \
  client/transport_local.cpp \
  client/mdns_utils.cpp \
  client/transport_usb.cpp \
  client/pairing/pairing_client.cpp \
  client/usb_linux.cpp

ADB_LIBDIAGUSBSRC := diagnose_usb/diagnose_usb.cpp

ADB_GENSRC := dummy.cpp

ADB_SOURCES := \
  $(foreach s, $(ADB_SRC),           packages/modules/adb/$s) \
  $(foreach s, $(ADB_LIBDIAGUSBSRC), system/core/$s) \
  $(foreach s, $(ADB_GENSRC),        system/$s)

ADB_SOURCES_CPP := $(filter %.cpp,$(ADB_SOURCES))
ADB_OBJECTS_CPP := $(ADB_SOURCES_CPP:.cpp=.o)

ADB_SOURCES_CC  := $(filter %.cc,$(ADB_SOURCES))
ADB_OBJECTS_CC  := $(ADB_SOURCES_CC:.cc=.o)

ADB_STATIC_LIBS := o/system/libadb.a o/system/libcrypto_utils.a

system/dummy.cpp:
	$(V_GEN)echo -e \
	    '#include <adb_wifi.h>\n' \
	    '#include <adb_mdns.h>\n' \
	    'void init_mdns_transport_discovery(void) {}\n' \
	    'std::string mdns_check() {return std::string("");}\n' \
	    'void mdns_cleanup() {}\n' \
	    'std::string mdns_list_discovered_services() {return std::string("");}\n' \
	    'std::optional<MdnsInfo> mdns_get_connect_service_info(const std::string& name) {return std::nullopt;}\n' \
	    'std::optional<MdnsInfo> mdns_get_pairing_service_info(const std::string& name) {return std::nullopt;}\n' \
	    'bool adb_secure_connect_by_service_name(const std::string& instance_name) {return false;}\n' > $@

############################################################################
# flags
# Note: proto headers and files are generated in the _build_
# tree and cannot be found via INCROOT:
ADB_CPPFLAGS := \
  -D_GNU_SOURCE \
  -DPLATFORM_TOOLS_VERSION='"$(PLATFORM_TOOLS_VERSION)"' \
  -DADB_HOST=1 \
  -DADB_VERSION='"$(PLATFORM_TOOLS_VERSION)"' \
  -DANDROID_BASE_UNIQUE_FD_DISABLE_IMPLICIT_CONVERSION=1 \
  -Ipackages/modules/fastdeploy/proto \
  -Ipackages/modules/adb/proto \
  -Ipackages/modules/adb \
  -I$(INCROOT)/packages/modules/adb \
  -I$(INCROOT)/packages/modules/adb/crypto/include \
  -I$(INCROOT)/packages/modules/adb/pairing_connection/include \
  -I$(INCROOT)/packages/modules/adb/tls/include \
  -I$(INCROOT)/system/core/diagnose_usb/include \
  -I$(INCROOT)/system/core/include \
  -I$(INCROOT)/system/core/libcrypto_utils/include \
  -I$(INCROOT)/system/libbase/include \
  -I$(INCROOT)/system/libziparchive/include \
  -I/usr/include/android \

ADB_LDFLAGS := \
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
  -lpthread \
  -lssl \
  -lusb-1.0 \
  -lziparchive \
  -lzstd \
  -pie

############################################################################
# dependencies and build flags
ADB_SODEPS := $(patsubst %,o/system/lib%.so,ziparchive cutils base log)

o/system/adb: CFLAGS   := $(BASE_CFLAGS)   $(ADB_CFLAGS)   $(EXTRA_CFLAGS)
o/system/adb: CPPFLAGS := $(BASE_CPPFLAGS) $(ADB_CPPFLAGS) $(EXTRA_CPPFLAGS)
o/system/adb: LDFLAGS  := $(BASE_LDFLAGS)  $(ADB_LDFLAGS)  $(EXTRA_LDFLAGS)
o/system/adb: CXXFLAGS := $(BASE_CXXFLAGS) $(ADB_CXXFLAGS) $(EXTRA_CXXFLAGS)
o/system/adb: | $(ADB_SODEPS)
o/system/adb: packages/modules/adb/proto/key_type.pb.h
o/system/adb: $(ADB_OBJECTS_CC) $(ADB_OBJECTS_CPP) $(ADB_STATIC_LIBS)

############################################################################
# built objects
OBJ_CC     += $(ADB_OBJECTS_CC)
OBJ_CPP    += $(ADB_OBJECTS_CPP)
BUILT      += o/system/adb

############################################################################
# clean
clean-adb: OBJ := $(ADB_OBJECTS_CC) $(ADB_OBJECTS_CPP)
clean-adb:
	@rm -vf $(OBJ)
	@rm -vf o/system/adb
	@for d in $(dir $(filter %.pb.o,$(OBJ))); do rm -vf $$d/*.pb.*; done

clean: clean-adb

############################################################################
# install
TOOLS     += o/system/adb

############################################################################
-include ../trace-build-exit.mk
