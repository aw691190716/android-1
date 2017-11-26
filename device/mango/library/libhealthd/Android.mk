LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_SRC_FILES := healthd_board_mango.cpp
LOCAL_MODULE := libhealthd.mango
LOCAL_C_INCLUDES := system/core/healthd/include
include $(BUILD_STATIC_LIBRARY)

