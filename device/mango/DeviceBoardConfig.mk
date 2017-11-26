BOARD_HAL_STATIC_LIBRARIES := libhealthd.mango
TARGET_CPU_VARIANT := cortex-a8

BOARD_SEPOLICY_DIRS := \
       vendor/google/device/mango/sepolicy \
       device/semc/msm7x30-common/sepolicy \
       device/semc/mogami-common/sepolicy

TARGET_SPECIFIC_HEADER_PATH += vendor/google/device/mango/include
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := vendor/google/device/mango/bluedroid
BOARD_KERNEL_PAGESIZE := 4096
