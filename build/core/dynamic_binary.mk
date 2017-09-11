# Likewise for recovery and utility executables
ifeq ($(LOCAL_MODULE_CLASS),RECOVERY_EXECUTABLES)
  my_pack_module_relocations := false
endif
ifeq ($(LOCAL_MODULE_CLASS),UTILITY_EXECUTABLES)
  my_pack_module_relocations := false
endif