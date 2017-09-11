PRODUCT_COPY_FILES := vendor/cm/prebuilt/common/etc/apns-conf.xml:system/etc/apns-conf.xml

-include device/semc/mango/lineage.mk

PRODUCT_NAME := mango

PRODUCT_PROPERTY_OVERRIDES += \
    ro.com.android.dataroaming=true \
    persist.sys.usb.config="mtp,adb" \
    persist.sys.root_access=3 \
    persist.sys.locale=zh-CN

PRODUCT_PACKAGES += \
    mkfs.f2fs \
    MangoService
