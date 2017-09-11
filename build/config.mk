VENDOR_CM := $(TOPDIR)vendor/cm
VENDOR_GOOGLe := $(TOPDIR)vendor/google
VENDOR_CM_BUILD_SYSTEM := $(VENDOR_CM)/build/core
VENDOR_GOOGLe_BUILD_SYSTEM := $(VENDOR_GOOGLe)/build/core
LOCAL_ADDITIONAL_DEPENDENCIES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr
TARGET_SPECIFIC_HEADER_PATH += $(VENDOR_GOOGLe)/include

-include $(VENDOR_CM_BUILD_SYSTEM)/config.mk
-include $(VENDOR_CM_BUILD_SYSTEM)/definitions.mk
-include $(VENDOR_GOOGLe_BUILD_SYSTEM)/definitions.mk

$(call project-set-path-variant,recovery,RECOVERY_VARIANT,bootable/recovery)

MKYAFFS2 := $(HOST_OUT_EXECUTABLES)/mkyaffs2image$(HOST_EXECUTABLE_SUFFIX)
MKIMAGE :=  $(HOST_OUT_EXECUTABLES)/mkimage$(HOST_EXECUTABLE_SUFFIX)

-include $(VENDOR_CM_BUILD_SYSTEM)/qcom_target.mk

DEVICE_PACKAGE_OVERLAYS += $(VENDOR_CM)/overlay

recovery_uncompressed_ramdisk := $(PRODUCT_OUT)/ramdisk-recovery.cpio

ifeq ($(TARGET_USERIMAGES_USE_YAFFS),true)
INTERNAL_USERIMAGES_USE_YAFFS := true
INTERNAL_USERIMAGES_DEPS += $(SIMG2IMG)
INTERNAL_USERIMAGES_DEPS += $(MKYAFFS2)
endif

PRODUCT_PACKAGE_OVERLAYS += $(VENDOR_GOOGLe)/overlay

BOARD_SEPOLICY_DIRS += \
       $(VENDOR_GOOGLe)/sepolicy \
       $(VENDOR_CM)/sepolicy

TARGET_DISABLE_CMSDK := true
WITHOUT_CHECK_API := true
WITH_DEXPREOPT := false

ifeq ($(HOST_OS),linux)
  KERNEL_TOOLCHAIN := $(ANDROID_BUILD_TOP)/prebuilts/gcc/linux-x86/arm/arm-eabi-4.8/bin
else
  KERNEL_TOOLCHAIN := $(ANDROID_BUILD_TOP)/prebuilts/gcc/darwin-x86/arm/arm-eabi-4.8/bin
endif