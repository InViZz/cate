include theos/makefiles/common.mk

TWEAK_NAME = cate
cate_FILES = Tweak.xm PlugIn.m
cate_FRAMEWORKS = CoreTelephony UIKit

include $(THEOS_MAKE_PATH)/tweak.mk
