
ifeq ($(HOST_OS),linux)
  KERNEL_TOOLCHAIN := $(ANDROID_BUILD_TOP)/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin
else
  KERNEL_TOOLCHAIN := $(ANDROID_BUILD_TOP)/prebuilts/gcc/darwin-x86/aarch64/aarch64-linux-android-4.9/bin
endif
