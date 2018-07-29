LOCAL_PATH:= $(call my-dir)

ifeq ($(debug_init), true)
include $(CLEAR_VARS)
LOCAL_MODULE       := init_prebuilt
LOCAL_MODULE_TAGS  := optional eng
LOCAL_MODULE_CLASS := ETC
LOCAL_SRC_FILES    := $(LOCAL_MODULE)
LOCAL_MODULE_PATH  := $(TARGET_ROOT_OUT)
LOCAL_REQUIRED_MODULES := init
LOCAL_POST_INSTALL_CMD := $(hide) mv $(TARGET_ROOT_OUT)/init_prebuilt $(TARGET_ROOT_OUT)/init; \
    mkdir -p $(TARGET_ROOT_OUT)/sbin; \
    ln -sf ../init $(TARGET_ROOT_OUT)/sbin/ueventd; \
    ln -sf ../init $(TARGET_ROOT_OUT)/sbin/watchdogd
include $(BUILD_PREBUILT)
endif

ifneq ($(TARGET_LD_SHIM_LIBS),)
LOCAL_PATH:=
include $(CLEAR_VARS)
LOCAL_MODULE_TAGS  := optional eng
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE       := init.environ.rc_prebuilt
LOCAL_MODULE_PATH := $(TARGET_ROOT_OUT)
LOCAL_REQUIRED_MODULES := init.environ.rc
LOCAL_SRC_FILES    := $(TARGET_OUT_INTERMEDIATES)/ETC/init.environ.rc_intermediates/init.environ.rc
LOCAL_POST_INSTALL_CMD :=$(hide) echo '    export LD_SHIM_LIBS $(TARGET_LD_SHIM_LIBS)' >> $(TARGET_ROOT_OUT)/init.environ.rc
include $(BUILD_PREBUILT)
endif
