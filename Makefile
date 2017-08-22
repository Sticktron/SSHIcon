ARCHS = armv7 arm64
TARGET = iphone:clang:10.1:10.0

THEOS_BUILD_DIR = Build

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SSHIcon

SSHIcon_FILES = Tweak.xm
SSHIcon_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += Settings
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 SpringBoard"
