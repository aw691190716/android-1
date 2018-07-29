VENDOR_GOOGLe := $(TOPDIR)vendor/google
VENDOR_GOOGLe_BUILD_SYSTEM := $(VENDOR_GOOGLe)/build/core
LOCAL_ADDITIONAL_DEPENDENCIES += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr

ifneq ($(VENDOR_ROM),)
ifeq ($(VENDOR_ROM)/build/core, $(wildcard $(VENDOR_ROM)/build/core))
VENDOR_ROM_BUILD_SYSTEM := $(VENDOR_ROM)/build/core
-include $(VENDOR_ROM_BUILD_SYSTEM)/config.mk
-include $(VENDOR_ROM_BUILD_SYSTEM)/definitions.mk
endif
endif

-include $(VENDOR_GOOGLe_BUILD_SYSTEM)/definitions.mk

ifeq ($(call project-path-for,recovery),)
$(call project-set-path-variant,recovery,RECOVERY_VARIANT,bootable/recovery)
endif

MKYAFFS2 := $(HOST_OUT_EXECUTABLES)/mkyaffs2image$(HOST_EXECUTABLE_SUFFIX)
MKIMAGE :=  $(HOST_OUT_EXECUTABLES)/mkimage$(HOST_EXECUTABLE_SUFFIX)

-include $(VENDOR_ROM_BUILD_SYSTEM)/qcom_target.mk
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

