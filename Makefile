ARCHS = armv7 arm64
TARGET = iphone:clang:10.1:9.3

THEOS_BUILD_DIR = Build

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SSHIconUI SSHIconSB
SSHIconUI_FILES = SSHIconUI.xm
SSHIconUI_CFLAGS = -fobjc-arc
SSHIconSB_FILES = SSHIconSB.xm
SSHIconSB_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += Settings
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 SpringBoard"
