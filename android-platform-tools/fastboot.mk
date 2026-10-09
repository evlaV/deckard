-include ../trace-build-init.mk
############################################################################
# sources
FASTBOOT_SOURCES := \
  system/core/fastboot/bootimg_utils.cpp \
  system/core/fastboot/fastboot_driver.cpp \
  system/core/fastboot/fastboot.cpp \
  system/core/fastboot/filesystem.cpp \
  system/core/fastboot/fs.cpp \
  system/core/fastboot/main.cpp \
  system/core/fastboot/socket.cpp \
  system/core/fastboot/storage.cpp \
  system/core/fastboot/super_flash_helper.cpp \
  system/core/fastboot/tcp.cpp \
  system/core/fastboot/udp.cpp \
  system/core/fastboot/util.cpp \
  system/core/fastboot/vendor_boot_img_utils.cpp \
  system/core/fastboot/task.cpp \
  system/core/fastboot/usb_linux.cpp \
  system/core/fs_mgr/liblp/builder.cpp \
  system/core/fs_mgr/liblp/super_layout_builder.cpp \
  system/core/fs_mgr/liblp/images.cpp \
  system/core/fs_mgr/liblp/partition_opener.cpp \
  system/core/fs_mgr/liblp/property_fetcher.cpp \
  system/core/fs_mgr/liblp/reader.cpp \
  system/core/fs_mgr/liblp/utility.cpp \
  system/core/fs_mgr/liblp/writer.cpp

FASTBOOT_SOURCES_CPP := $(filter %.cpp,$(FASTBOOT_SOURCES))
FASTBOOT_OBJECTS_CPP := $(FASTBOOT_SOURCES_CPP:.cpp=.o)

FASTBOOT_STATIC_LIBS := o/system/libadb.a o/system/libext4_utils.a

############################################################################
# flags
FASTBOOT_CXXFLAGS := -fpermissive
FASTBOOT_CPPFLAGS := \
  -D_FILE_OFFSET_BITS=64 \
  -DPLATFORM_TOOLS_VERSION='"$(PLATFORM_TOOLS_VERSION)"' \
  -I$(INCROOT)/external/avb \
  -I$(INCROOT)/external/fmtlib/include \
  -Ipackages/modules/adb/proto \
  -Ipackages/modules/adb \
  -I$(INCROOT)/system/core/demangle/include \
  -I$(INCROOT)/system/core/diagnose_usb/include \
  -I$(INCROOT)/system/core/fs_mgr/include \
  -I$(INCROOT)/system/core/fs_mgr/include_fstab \
  -I$(INCROOT)/system/core/fs_mgr/liblp/include \
  -I$(INCROOT)/system/core/fs_mgr/libstorage_literals \
  -I$(INCROOT)/system/core/include \
  -I$(INCROOT)/system/core/libcutils/include \
  -I$(INCROOT)/system/core/libsparse/include \
  -I$(INCROOT)/system/extras/ext4_utils/include \
  -I$(INCROOT)/system/libbase/include \
  -I$(INCROOT)/system/libziparchive/include \
  -I$(INCROOT)/system/tools/mkbootimg/include/bootimg \
  -I/usr/include/android

FASTBOOT_LDFLAGS := \
  -Lo/system \
  -L/usr/lib/$(CARCH)/android \
  -Wl,-rpath=/usr/lib/$(CARCH)/android \
  -lbase \
  -lcrypto \
  -lcutils \
  -llog \
  -lpthread \
  -lprotobuf \
  -lsparse \
  -lusb-1.0 \
  -lziparchive \
  -pie

############################################################################
# dependencies and build flags
FASTBOOT_SODEPS := $(patsubst %,o/system/lib%.so,base log cutils sparse ziparchive)

o/system/fastboot: CFLAGS   := $(BASE_CFLAGS)   $(FASTBOOT_CFLAGS)   $(EXTRA_CFLAGS)
o/system/fastboot: CPPFLAGS := $(BASE_CPPFLAGS) $(FASTBOOT_CPPFLAGS) $(EXTRA_CPPFLAGS)
o/system/fastboot: LDFLAGS  := $(BASE_LDFLAGS)  $(FASTBOOT_LDFLAGS)  $(EXTRA_LDFLAGS)
o/system/fastboot: CXXFLAGS := $(BASE_CXXFLAGS) $(FASTBOOT_CXXFLAGS) $(EXTRA_CXXFLAGS)
o/system/fastboot: | $(FASTBOOT_SODEPS)
o/system/fastboot: $(FASTBOOT_OBJECTS_CPP) $(FASTBOOT_STATIC_LIBS)

############################################################################
# built objects
OBJ_CPP    += $(FASTBOOT_OBJECTS_CPP)
BUILT      += o/system/fastboot

############################################################################
# clean
clean-fastboot: OBJ := $(FASTBOOT_OBJECTS_CPP)
clean-fastboot:
	@rm -vf $(OBJ)
	@rm -vf o/system/fastboot
	@for d in $(dir $(filter %.pb.o,$(OBJ))); do rm -vf $$d/*.pb.*; done

clean: clean-fastboot

############################################################################
# install
TOOLS += o/system/fastboot

############################################################################
-include ../trace-build-exit.mk
