-include ../trace-build-init.mk
############################################################################
# sources
LLOG_SOURCES := \
  system/logging/liblog/log_event_list.cpp \
  system/logging/liblog/log_event_write.cpp \
  system/logging/liblog/logger_name.cpp \
  system/logging/liblog/logger_read.cpp \
  system/logging/liblog/logger_write.cpp \
  system/logging/liblog/logprint.cpp \
  system/logging/liblog/properties.cpp \
  system/logging/liblog/event_tag_map.cpp \

LLOG_SOURCES_CPP := $(filter %.cpp,$(LLOG_SOURCES))
LLOG_OBJECTS_CPP := $(LLOG_SOURCES_CPP:.cpp=.o)

LLOG_SOURCES_CC  := $(filter %.cc,$(LLOG_SOURCES))
LLOG_OBJECTS_CC  := $(LLOG_SOURCES_CC:.cc=.o)

LLOG_SO_MAJOR    := 0

############################################################################
# flags
LLOG_CXXFLAGS := -fcommon

LLOG_CPPFLAGS := \
  -DLIBLOG_LOG_TAG=1006 \
  -DSNET_EVENT_LOG_TAG=1397638484 \
  -I$(INCROOT)/system/core/include \
  -I$(INCROOT)/system/core/libcutils/include \
  -I$(INCROOT)/system/libbase/include \
  -I$(INCROOT)/system/logging/liblog/include \

LLOG_LDFLAGS := \
  -Wl,-soname,liblog.so.$(LLOG_SO_MAJOR) \
  -lpthread \
  -shared

############################################################################
# dependencies and build flags
o/system/liblog.so: CFLAGS   := $(BASE_CFLAGS)   $(LLOG_CFLAGS)   $(EXTRA_CFLAGS)
o/system/liblog.so: CPPFLAGS := $(BASE_CPPFLAGS) $(LLOG_CPPFLAGS) $(EXTRA_CPPFLAGS)
o/system/liblog.so: LDFLAGS  := $(BASE_LDFLAGS)  $(LLOG_LDFLAGS)  $(EXTRA_LDFLAGS)
o/system/liblog.so: CXXFLAGS := $(BASE_CXXFLAGS) $(LLOG_CXXFLAGS) $(EXTRA_CXXFLAGS)
o/system/liblog.so: SO_MAJOR := $(LLOG_SO_MAJOR)
o/system/liblog.so: $(LLOG_OBJECTS_CC) $(LLOG_OBJECTS_CPP)

OBJ_CC  += $(LLOG_OBJECTS_CC)
OBJ_CPP += $(LLOG_OBJECTS_CPP)
BUILT   += o/system/liblog.so

############################################################################
# clean
clean-liblog.so:
	@rm -vf $(LLOG_OBJECTS_CC) $(LLOG_OBJECTS_CPP)
	@rm -vf o/system/liblog.so{,.$(LLOG_SO_MAJOR)}

clean: clean-liblog.so

############################################################################
# install
INCLUDES  += $(wildcard $(INCROOT)/system/logging/liblog/include/android/*)
INCLUDES  += $(INCROOT)/system/logging/liblog/include/log
LIBRARIES += o/system/liblog.so
LIBRARIES += o/system/liblog.so.$(LLOG_SO_MAJOR)

############################################################################
-include ../trace-build-exit.mk
