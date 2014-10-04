ARCHS = armv7 armv7s arm64

include theos/makefiles/common.mk

BUNDLE_NAME = HCL7Settings
HCL7Settings_FILES = HCL7Settings.mm
HCL7Settings_INSTALL_PATH = /Library/PreferenceBundles
HCL7Settings_FRAMEWORKS = UIKit
HCL7Settings_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/HCL7Settings.plist$(ECHO_END)
