device_board_config_mk := \
	$(strip $(sort $(wildcard \
		$(shell test -d vendor && find -L vendor -maxdepth 4 -path '*/$(TARGET_DEVICE)/DeviceBoardConfig.mk') \
	)))

ifneq ($(device_board_config_mk),)
ifneq ($(words $(device_board_config_mk)),1)
  $(error Multiple board config files for TARGET_DEVICE $(TARGET_DEVICE): $(device_board_config_mk))
endif
-include $(device_board_config_mk)
endif

ifneq ($(DELETE_PRODUCT_COPY_FILES),)
PRODUCT_COPY_FILES := $(filter-out $(DELETE_PRODUCT_COPY_FILES), $(PRODUCT_COPY_FILES))
endif

ifneq ($(DELETE_PRODUCT_PROPERTY_OVERRIDES),)
ADDITIONAL_BUILD_PROPERTIES := $(filter-out $(DELETE_PRODUCT_PROPERTY_OVERRIDES), $(ADDITIONAL_BUILD_PROPERTIES))
PRODUCT_PROPERTY_OVERRIDES := $(filter-out $(DELETE_PRODUCT_PROPERTY_OVERRIDES), $(PRODUCT_PROPERTY_OVERRIDES))
PRODUCTS.$(INTERNAL_PRODUCT).PRODUCT_PROPERTY_OVERRIDES := $(filter-out $(DELETE_PRODUCT_PROPERTY_OVERRIDES), $(PRODUCTS.$(INTERNAL_PRODUCT).PRODUCT_PROPERTY_OVERRIDES))
endif

ifneq ($(DELETE_PRODUCT_BOOT_JARS),)
PRODUCT_BOOT_JARS := $(filter-out $(DELETE_PRODUCT_BOOT_JARS), $(PRODUCT_BOOT_JARS))
endif
