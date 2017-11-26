define build-recoveryramdisk
  @echo ----- Making recovery ramdisk ------
  $(hide) mkdir -p $(TARGET_RECOVERY_OUT)
  $(hide) mkdir -p $(TARGET_RECOVERY_ROOT_OUT)/etc $(TARGET_RECOVERY_ROOT_OUT)/sdcard $(TARGET_RECOVERY_ROOT_OUT)/tmp
  @echo Copying baseline ramdisk...
  $(hide) rsync -a --exclude=etc --exclude=sdcard $(IGNORE_CACHE_LINK) $(TARGET_ROOT_OUT) $(TARGET_RECOVERY_OUT) # "cp -Rf" fails to overwrite broken symlinks on Mac.
  @echo Modifying ramdisk contents...
  $(hide) rm -f $(TARGET_RECOVERY_ROOT_OUT)/init*.rc
  $(hide) cp -f $(recovery_initrc) $(TARGET_RECOVERY_ROOT_OUT)/
  $(hide) rm -f $(TARGET_RECOVERY_ROOT_OUT)/sepolicy
  $(hide) cp -f $(recovery_sepolicy) $(TARGET_RECOVERY_ROOT_OUT)/sepolicy
  $(hide) cp $(TARGET_ROOT_OUT)/init.recovery.*.rc $(TARGET_RECOVERY_ROOT_OUT)/ || true # Ignore error when the src file doesn't exist.
  $(hide) mkdir -p $(TARGET_RECOVERY_ROOT_OUT)/res
  $(hide) rm -rf $(TARGET_RECOVERY_ROOT_OUT)/res/*
  $(hide) cp -rf $(recovery_resources_common)/* $(TARGET_RECOVERY_ROOT_OUT)/res
  $(hide) cp -f $(recovery_font) $(TARGET_RECOVERY_ROOT_OUT)/res/images/font.png
  $(hide) $(foreach item,$(TARGET_PRIVATE_RES_DIRS), \
    cp -rf $(item) $(TARGET_RECOVERY_ROOT_OUT)/$(newline))
  $(hide) $(if $(strip $(DEVICE_RECOVERY_FSTAB)), \
  $(foreach item,$(DEVICE_RECOVERY_FSTAB), \
    cp -f $(item) $(TARGET_RECOVERY_ROOT_OUT)/etc/recovery.fstab))
  $(if $(strip $(recovery_wipe)), \
    $(hide) cp -f $(recovery_wipe) $(TARGET_RECOVERY_ROOT_OUT)/etc/recovery.wipe)
  $(hide) cp $(RECOVERY_INSTALL_OTA_KEYS) $(TARGET_RECOVERY_ROOT_OUT)/res/keys
  $(hide) cat $(INSTALLED_DEFAULT_PROP_TARGET) $(recovery_build_prop) \
          > $(TARGET_RECOVERY_ROOT_OUT)/default.prop
  $(BOARD_RECOVERY_IMAGE_PREPARE)
  $(if $(filter true,$(BOARD_BUILD_SYSTEM_ROOT_IMAGE)), \
    $(hide) mkdir -p $(TARGET_RECOVERY_ROOT_OUT)/system_root; \
            rm -rf $(TARGET_RECOVERY_ROOT_OUT)/system; \
            ln -sf /system_root/system $(TARGET_RECOVERY_ROOT_OUT)/system) # Mount the system_root_image to /system_root and symlink /system.
endef

define build-recoveryimage-target
  $(if $(filter true,$(PRODUCTS.$(INTERNAL_PRODUCT).PRODUCT_SUPPORTS_VBOOT)), \
    $(hide) $(MKBOOTIMG) $(INTERNAL_RECOVERYIMAGE_ARGS) $(INTERNAL_MKBOOTIMG_VERSION_ARGS) $(BOARD_MKBOOTIMG_ARGS) --output $(1).unsigned, \
    $(hide) $(MKBOOTIMG) $(INTERNAL_RECOVERYIMAGE_ARGS) $(INTERNAL_MKBOOTIMG_VERSION_ARGS) $(BOARD_MKBOOTIMG_ARGS) --output $(1) --id > $(RECOVERYIMAGE_ID_FILE))
  $(if $(filter true,$(PRODUCTS.$(INTERNAL_PRODUCT).PRODUCT_SUPPORTS_BOOT_SIGNER)),\
    $(if $(filter true,$(BOARD_USES_RECOVERY_AS_BOOT)),\
      $(BOOT_SIGNER) /boot $(1) $(PRODUCTS.$(INTERNAL_PRODUCT).PRODUCT_VERITY_SIGNING_KEY).pk8 $(PRODUCTS.$(INTERNAL_PRODUCT).PRODUCT_VERITY_SIGNING_KEY).x509.pem $(1),\
      $(BOOT_SIGNER) /recovery $(1) $(PRODUCTS.$(INTERNAL_PRODUCT).PRODUCT_VERITY_SIGNING_KEY).pk8 $(PRODUCTS.$(INTERNAL_PRODUCT).PRODUCT_VERITY_SIGNING_KEY).x509.pem $(1)\
    )\
  )
  $(if $(filter true,$(PRODUCTS.$(INTERNAL_PRODUCT).PRODUCT_SUPPORTS_VBOOT)), \
    $(VBOOT_SIGNER) $(FUTILITY) $(1).unsigned $(PRODUCTS.$(INTERNAL_PRODUCT).PRODUCT_VBOOT_SIGNING_KEY).vbpubk $(PRODUCTS.$(INTERNAL_PRODUCT).PRODUCT_VBOOT_SIGNING_KEY).vbprivk $(PRODUCTS.$(INTERNAL_PRODUCT).PRODUCT_VBOOT_SIGNING_SUBKEY).vbprivk $(1).keyblock $(1))
  $(if $(filter true,$(BOARD_USES_RECOVERY_AS_BOOT)), \
    $(hide) $(call assert-max-image-size,$(1),$(BOARD_BOOTIMAGE_PARTITION_SIZE)), \
    $(hide) $(call assert-max-image-size,$(1),$(BOARD_RECOVERYIMAGE_PARTITION_SIZE)))
  @echo ----- Made recovery image: $(1) --------
endef

ifeq ($(BOARD_USES_RECOVERY_AS_BOOT),true)
ifeq (true,$(PRODUCTS.$(INTERNAL_PRODUCT).PRODUCT_SUPPORTS_BOOT_SIGNER))
$(INSTALLED_BOOTIMAGE_TARGET) : $(BOOT_SIGNER)
endif
ifeq (true,$(PRODUCTS.$(INTERNAL_PRODUCT).PRODUCT_SUPPORTS_VBOOT))
$(INSTALLED_BOOTIMAGE_TARGET) : $(VBOOT_SIGNER)
endif
$(INSTALLED_BOOTIMAGE_TARGET): $(MKBOOTFS) $(MKBOOTIMG) $(MINIGZIP) \
		$(INSTALLED_RAMDISK_TARGET) \
		$(INTERNAL_RECOVERYIMAGE_FILES) \
		$(recovery_initrc) $(recovery_sepolicy) $(recovery_kernel) \
		$(INSTALLED_2NDBOOTLOADER_TARGET) \
		$(recovery_build_prop) $(recovery_resource_deps) \
		$(recovery_fstab) \
		$(RECOVERY_INSTALL_OTA_KEYS)
		$(call pretty,"Target boot image from recovery: $@")
		$(call build-recoveryramdisk)
		$(hide) $(MKBOOTFS) $(TARGET_RECOVERY_ROOT_OUT) > $(recovery_uncompressed_ramdisk)
		$(hide) $(MINIGZIP) < $(recovery_uncompressed_ramdisk) > $(recovery_ramdisk)
		$(call build-recoveryimage-target, $@)
endif

recovery_uncompressed_ramdisk := $(PRODUCT_OUT)/ramdisk-recovery.cpio

$(recovery_uncompressed_ramdisk): $(MKBOOTFS) \
		$(INSTALLED_RAMDISK_TARGET) \
		$(INSTALLED_BOOTIMAGE_TARGET) \
		$(INTERNAL_RECOVERYIMAGE_FILES) \
		$(recovery_initrc) $(recovery_sepolicy) \
		$(INSTALLED_2NDBOOTLOADER_TARGET) \
		$(recovery_build_prop) $(recovery_resource_deps) \
		$(recovery_fstab) \
		$(RECOVERY_INSTALL_OTA_KEYS)
	$(call build-recoveryramdisk)
	@echo "----- Making uncompressed recovery ramdisk ------"
	$(hide) $(MKBOOTFS) $(TARGET_RECOVERY_ROOT_OUT) > $@

$(recovery_ramdisk): $(MINIGZIP) \
		$(recovery_uncompressed_ramdisk)
	@echo "----- Making compressed recovery ramdisk ------"
	$(hide) $(MINIGZIP) < $(recovery_uncompressed_ramdisk) > $@

ifndef BOARD_CUSTOM_BOOTIMG_MK
$(INSTALLED_RECOVERYIMAGE_TARGET): $(MKBOOTIMG) $(recovery_ramdisk) $(recovery_kernel) \
		$(RECOVERYIMAGE_EXTRA_DEPS)
	@echo "----- Making recovery image ------"
	$(call build-recoveryimage-target, $@)
endif # BOARD_CUSTOM_BOOTIMG_MK

ifneq ($(INSTALLED_RECOVERYIMAGE_TARGET),)
intermediates := $(call intermediates-dir-for,PACKAGING,recovery_patch)
ifndef BOARD_CANT_BUILD_RECOVERY_FROM_BOOT_PATCH
RECOVERY_FROM_BOOT_PATCH := $(intermediates)/recovery_from_boot.p
else
RECOVERY_FROM_BOOT_PATCH :=
endif
$(RECOVERY_FROM_BOOT_PATCH): $(INSTALLED_RECOVERYIMAGE_TARGET) \
                             $(INSTALLED_BOOTIMAGE_TARGET) \
			     $(HOST_OUT_EXECUTABLES)/imgdiff \
	                     $(HOST_OUT_EXECUTABLES)/bsdiff
	@echo "Construct recovery from boot"
	mkdir -p $(dir $@)
	PATH=$(HOST_OUT_EXECUTABLES):$$PATH $(HOST_OUT_EXECUTABLES)/imgdiff $(INSTALLED_BOOTIMAGE_TARGET) $(INSTALLED_RECOVERYIMAGE_TARGET) $@
endif

ifdef RECOVERY_RESOURCE_ZIP
$(RECOVERY_RESOURCE_ZIP): $(INSTALLED_RECOVERYIMAGE_TARGET) | $(ZIPTIME)
	$(hide) mkdir -p $(dir $@)
	$(hide) find $(TARGET_RECOVERY_ROOT_OUT)/res -type f | sort | zip -0qrjX $@ -@
	$(remove-timestamps-from-package)
endif

.PHONY: recoveryimage-nodeps
recoveryimage-nodeps:
	@echo "make $@: ignoring dependencies"
	$(call build-recoveryramdisk)
	$(hide) $(MKBOOTFS) $(TARGET_RECOVERY_ROOT_OUT) > $(recovery_uncompressed_ramdisk)
	$(hide) $(MINIGZIP) < $(recovery_uncompressed_ramdisk) > $(recovery_ramdisk)
	$(call build-recoveryimage-target, $(INSTALLED_RECOVERYIMAGE_TARGET))


ifdef BOARD_CUSTOM_BOOTIMG_MK
-include $(BOARD_CUSTOM_BOOTIMG_MK)
endif

ifneq ($(BLOCK_BASED_OTA),false)
    $(INTERNAL_OTA_PACKAGE_TARGET): block_based := --block
endif

$(INTERNAL_OTA_PACKAGE_TARGET): $(BUILT_TARGET_FILES_PACKAGE)
	@echo "Package OTA: $@"
	$(hide) PATH=$(foreach p,$(INTERNAL_USERIMAGES_BINARY_PATHS),$(p):)$$PATH MKBOOTIMG=$(MKBOOTIMG) \
	   ./build/tools/releasetools/ota_from_target_files -v \
	   $(block_based) \
	   -p $(HOST_OUT) \
	   -k $(KEY_CERT_PAIR) \
	   $(if $(OEM_OTA_CONFIG), -o $(OEM_OTA_CONFIG)) \
	   $(BUILT_TARGET_FILES_PACKAGE) $@

CM_TARGET_PACKAGE := $(PRODUCT_OUT)/lineage-$(LINEAGE_VERSION).zip
.PHONY: bacon
bacon: otapackage
	$(hide) ln -f $(INTERNAL_OTA_PACKAGE_TARGET) $(CM_TARGET_PACKAGE)
	$(hide) $(MD5SUM) $(CM_TARGET_PACKAGE) | sed "s|$(PRODUCT_OUT)/||" > $(CM_TARGET_PACKAGE).md5sum
	@echo "Package Complete: $(CM_TARGET_PACKAGE)" >&2