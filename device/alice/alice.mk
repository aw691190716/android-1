PRODUCT_COPY_FILES := 
ifneq ($(VENDOR_ROM),)
apns-conf := $(VENDOR_ROM)/prebuilt/common/etc/apns-conf.xml
ifeq ($(apns-conf), $(wildcard $(apns-conf)))
PRODUCT_COPY_FILES += $(apns-conf):system/etc/apns-conf.xml
endif
apns-conf :=
endif
PRODUCT_COPY_FILES += vendor/google/device/alice/media_codecs.xml:system/etc/media_codecs.xml

LOCAL_PATH := device/huawei/alice
-include device/huawei/alice/rr.mk
LOCAL_PATH := $(call my-dir)

PRODUCT_NAME := alice
PRODUCT_PROPERTY_OVERRIDES += \
    ro.com.android.dataroaming=true \
    persist.sys.usb.config="mtp,adb" \
    persist.sys.locale=zh-CN \
    ro.config.hw_dsda=false \
    ro.config.dsds_mode=umts_gsm \
    ro.multi.rild=true \
    rild.libpath1=/system/lib64/libbalong-ril.so \
    persist.radio.modem.cap=09A94 \
    persist.radio.multisim.config=dsds \
    ro.telephony.default_network=9 \
    persist.dsds.enabled=true \
    rild.rild1_ready_to_start=true \
    rild.libpath=/system/lib64/libbalong-ril.so \
    ro.product.model=CHM-TL00H \
    ro.sys.sdcardfs=true \
    ro.modem_id=0X3DD51D00 \
    ril.balong_cid=d1c5 \
    ro.com.google.clientidbase=android-huawei \
    ro.build.selinux=1 \
    persist.sys.dun.override=0 \
    ro.storage_manager.enabled=true \
    ro.device.cache_dir=/data/cache

#    rild.libargs=-m modem0
#    rild.libargs1=-m modem1

DEVICE_PACKAGE_OVERLAYS := device/huawei/alice/overlay device/huawei/alice/overlay-lineage

PRODUCT_PACKAGES += init_prebuilt init.environ.rc_prebuilt

ifneq ($(VENDOR_ROM),)
delete_file := $(VENDOR_ROM)/prebuilt/common/etc/init.d/00banner
ifeq ($(delete_file), $(wildcard $(delete_file)))
PRODUCT_COPY_FILES += $(delete_file):system/etc/init.d/00banner
endif
delete_file := $(VENDOR_ROM)/prebuilt/common/bin/sysinit
ifeq ($(delete_file), $(wildcard $(delete_file)))
PRODUCT_COPY_FILES += $(delete_file):system/bin/sysinit
endif
delete_file := $(VENDOR_ROM)/prebuilt/common/etc/init.d/90userinit
ifeq ($(delete_file), $(wildcard $(delete_file)))
PRODUCT_COPY_FILES += $(delete_file):system/etc/init.d/90userinit
endif
delete_file :=
endif

BOARD_SEPOLICY_DIRS := 

DEVICE_RECOVERY_FSTAB := device/huawei/alice/rootdir/fstab.hi6210sft

DELETE_PRODUCT_PROPERTY_OVERRIDES += \
    media.sf.omx-plugin=libffmpeg_omx.so \
    media.sf.extractor-plugin=libffmpeg_extractor.so
