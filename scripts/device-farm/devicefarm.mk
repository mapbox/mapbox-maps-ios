# This should very closely match testspec.yml. 
# TODO: Determine if it's possible to upload a separate datafile (i.e. this makefile) to Device Farm

ROOT ?= /tmp
APP ?= MapboxTestHost.app

ifndef IPA_PATH
$(error Please define IPA_PATH)
endif

ifndef DEVICE_UDID
$(error Please define DEVICE_UDID)
endif

TEST_ROOT_PATH := $(ROOT)/test-root
UNZIPPED_IPA_PATH := $(ROOT)/unzipped-ipa
BUILD_PATH := $(ROOT)/build

$(TEST_ROOT_PATH) $(BUILD_PATH):
	-mkdir -p $@

.PHONY: pre_test test all

all: pre_test test

pre_test: | $(TEST_ROOT_PATH) $(BUILD_PATH)
	@echo "Unzipping IPA"
	unzip $(IPA_PATH) -d $(UNZIPPED_IPA_PATH)

	@echo "Moving testrun package to correct location"
	mv $(UNZIPPED_IPA_PATH)/Payload/$(APP)/xctestrun.zip $(ROOT)/xctestrun.zip
	unzip $(ROOT)/xctestrun.zip -d $(TEST_ROOT_PATH)

	@echo "Moving app into location required by test run"
	CONFIG=`cat $(TEST_ROOT_PATH)/configuration.txt` && \
		cp -R $(UNZIPPED_IPA_PATH)/Payload/$(APP) $(TEST_ROOT_PATH)/$$CONFIG-iphoneos

test:
	CONFIG=`cat $(TEST_ROOT_PATH)/configuration.txt` && \
		SCHEME=`cat $(TEST_ROOT_PATH)/scheme.txt` && \
    	DATE=`date +"%Y-%m-%d_%H%M%S"` && \
	    cd $(TEST_ROOT_PATH) && \
		xcodebuild test-without-building \
			-destination id=$(DEVICE_UDID) \
			-xctestrun device.xctestrun \
			-derivedDataPath $(BUILD_PATH) \
			-resultBundlePath $(BUILD_PATH)/$$SCHEME.$$CONFIG.$$DATE.xcresult
