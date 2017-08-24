ARCHS = armv7 arm64
TARGET = iphone:clang:10.1:9.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = SSHIconSettings
SSHIconSettings_FILES = SSHIconSettingsController.m
SSHIconSettings_INSTALL_PATH = /Library/PreferenceBundles
SSHIconSettings_PRIVATE_FRAMEWORKS = Preferences
SSHIconSettings_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/SSHIconSettingsSettings.plist$(ECHO_END)
