ARCHS = armv7 arm64
TARGET = iphone:clang:10.1:9.3


#export THEOS_DEVICE_IP = i4s
#export THEOS_DEVICE_IP = ip4s
#export THEOS_DEVICE_IP = ipad
#export THEOS_DEVICE_IP = ip6
export THEOS_DEVICE_IP = ip7
#export THEOS_DEVICE_IP = ip5s
#export THEOS_DEVICE_IP = ip5


THEOS_BUILD_DIR = Build

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SSHIconUI SSHIconSB

SSHIconUI_FILES = SSHIconUI.xm SSHIconConnectionInfo.m
SSHIconUI_CFLAGS = -fobjc-arc

SSHIconSB_FILES = SSHIconSB.xm SSHIconConnectionInfo.m
SSHIconSB_CFLAGS = -fobjc-arc


PACKAGE_VERSION = $(THEOS_PACKAGE_BASE_VERSION)
_THEOS_INTERNAL_PACKAGE_VERSION = $(THEOS_PACKAGE_BASE_VERSION)



include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += Settings
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 SpringBoard"
