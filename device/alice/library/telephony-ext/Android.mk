ifeq ($(TARGET_BUILD_JAVA_SUPPORT_LEVEL),platform)

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_JAVA_LIBRARIES := telephony-common
LOCAL_SRC_FILES := $(call all-java-files-under, telephony/java) \
    $(call all-Iaidl-files-under, telephony/java) \
    $(call all-logtags-files-under, telephony/java)

LOCAL_MODULE_TAGS := optional
LOCAL_MODULE := telephony-common-ext

include $(BUILD_JAVA_LIBRARY)

include $(call all-makefiles-under,$(LOCAL_PATH))
endif # JAVA platform
