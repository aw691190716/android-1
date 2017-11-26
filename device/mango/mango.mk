PRODUCT_COPY_FILES := vendor/cm/prebuilt/common/etc/apns-conf.xml:system/etc/apns-conf.xml
PRODUCT_COPY_FILES += vendor/google/device/mango/Generic.kl:system/usr/keylayout/Generic.kl
PRODUCT_COPY_FILES += vendor/google/device/mango/init.semc.rc:root/init.semc.rc
PRODUCT_COPY_FILES += vendor/google/device/mango/init.recovery.semc.rc:root/init.recovery.semc.rc
PRODUCT_COPY_FILES += vendor/google/device/mango/media_codecs.xml:system/etc/media_codecs.xml

-include device/semc/mango/lineage.mk

PRODUCT_NAME := mango
export CM_BUILD=mango
TARGET_USERIMAGES_USE_EXT4 := true
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 956633088
DEVICE_RECOVERY_FSTAB := vendor/google/device/mango/recovery.fstab
PRODUCT_PROPERTY_OVERRIDES += \
    ro.com.android.dataroaming=true \
    persist.sys.usb.config="mtp,adb" \
    persist.sys.root_access=3 \
    persist.sys.locale=zh-CN

PRODUCT_PACKAGES += \
    mkfs.f2fs \
    MangoService \
    toybox_init

DEVICE_PACKAGE_OVERLAYS = \
    vendor/google/device/mango/overlay \
    device/semc/mogami-common/overlay

DELETE_PRODUCT_COPY_FILES += \
    device/semc/msm7x30-common/rootdir/sbin/pre-recovery.sh:root/sbin/pre-recovery.sh \
    vendor/cm/prebuilt/common/etc/init.d/00banner:system/etc/init.d/00banner \
    vendor/cm/prebuilt/common/bin/sysinit:system/bin/sysinit \
    vendor/cm/prebuilt/common/etc/init.d/90userinit:system/etc/init.d/90userinit

DELETE_PRODUCT_PROPERTY_OVERRIDES += \
    ro.config.low_ram=true \
    media.sf.omx-plugin=libffmpeg_omx.so \
    media.sf.extractor-plugin=libffmpeg_extractor.so

DELETE_PRODUCT_BOOT_JARS += \
     telephony-ext

NOT_USE_CUSTOM_AUDIO_POLICY := true
PATH_CHERRIES += AOSP_547220 AOSP_547221 AOSP_547223 AOSP_547240 AOSP_547222