VENDOR_CM := $(TOPDIR)vendor/cm
VENDOR_GOOGLe := $(TOPDIR)vendor/google
VENDOR_CM_BUILD_SYSTEM := $(VENDOR_CM)/build/core
VENDOR_GOOGLe_BUILD_SYSTEM := $(VENDOR_GOOGLe)/build/core
LOCAL_ADDITIONAL_DEPENDENCIES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr

-include $(VENDOR_CM_BUILD_SYSTEM)/config.mk
-include $(VENDOR_CM_BUILD_SYSTEM)/definitions.mk
-include $(VENDOR_GOOGLe_BUILD_SYSTEM)/definitions.mk

$(call project-set-path-variant,recovery,RECOVERY_VARIANT,bootable/recovery)

MKYAFFS2 := $(HOST_OUT_EXECUTABLES)/mkyaffs2image$(HOST_EXECUTABLE_SUFFIX)
MKIMAGE :=  $(HOST_OUT_EXECUTABLES)/mkimage$(HOST_EXECUTABLE_SUFFIX)

-include $(VENDOR_CM_BUILD_SYSTEM)/qcom_target.mk
ifeq ($(NOT_USE_CUSTOM_AUDIO_POLICY),true)
USE_CUSTOM_AUDIO_POLICY:= 0
endif

ifeq ($(TARGET_USERIMAGES_USE_YAFFS),true)
INTERNAL_USERIMAGES_USE_YAFFS := true
INTERNAL_USERIMAGES_DEPS += $(SIMG2IMG)
INTERNAL_USERIMAGES_DEPS += $(MKYAFFS2)
MKEXTUSERIMG += $(MKYAFFS2) $(MKIMAGE)
endif
 
TARGET_DISABLE_CMSDK := true
WITHOUT_CHECK_API := true
WITH_DEXPREOPT := false

ifeq ($(HOST_OS),linux)
  KERNEL_TOOLCHAIN := $(ANDROID_BUILD_TOP)/prebuilts/gcc/linux-x86/arm/arm-eabi-4.8/bin
else
  KERNEL_TOOLCHAIN := $(ANDROID_BUILD_TOP)/prebuilts/gcc/darwin-x86/arm/arm-eabi-4.8/bin
endif

ifeq ($(BOARD_CACHEIMAGE_FILE_SYSTEM_TYPE),)
  ADDITIONAL_DEFAULT_PROPERTIES += \
    ro.device.cache_dir=/data/cache
else
  ADDITIONAL_DEFAULT_PROPERTIES += \
    ro.device.cache_dir=/cache
endif