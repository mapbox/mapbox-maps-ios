# ----------------------------------------------------------------------------------------------------------------------
# Configurable varibles
ifneq ($(XCODE_WORKSPACE),)
	XCODE_PROJECT := -workspace $(XCODE_WORKSPACE)
else
	XCODE_PROJECT ?= -project MapboxMaps.xcodeproj
endif

XCODE_PROJECT_FILE := MapboxMaps.xcodeproj/project.pbxproj

# Default to Debug since Release will require testability. (See #157)
CONFIGURATION    ?= Debug
BUILD_DIR        ?= $(CURDIR)/build
JOBS             ?= $(shell sysctl -n hw.ncpu)
APP_NAME         ?= $(SCHEME)

# Circle
CIRCLE_CI_CLI       ?= /usr/local/bin/circleci
CIRCLE_CI_BRANCH    ?= main
CIRCLE_BUILD_NUM    ?= 0

# Derived variables
BUILT_DEVICE_PRODUCTS_DIR := $(BUILD_DIR)/Build/Products/$(CONFIGURATION)-iphoneos
XCTESTRUN_PACKAGE         := $(BUILD_DIR)/$(SCHEME)-$(CONFIGURATION)-testrun.zip
TEST_ROOT                 := $(BUILD_DIR)/test-root
PAYLOAD_DIR               := $(BUILD_DIR)/Payload
DEVICE_TEST_PATH          := $(BUILD_DIR)/DeviceFarmResults

# Netrc
NETRC_FILE=~/.netrc

# See https://stackoverflow.com/a/7377522
define NETRC
machine api.mapbox.com
login mapbox
password $(SDK_REGISTRY_TOKEN)
endef
export NETRC


# Disabled optional code signing for the time-being. Currently with the setup below,
# when build-for-testing unit tests on device **locally** (i.e. you need code-signing),
# the build can fail with
#
#	error: Cycle inside MapboxMapsTests; building could produce unreliable results.
#
# This can be fixed by adding MapboxMapTestHost as a dependency to the Test targets,
# but this isn't the appropriate a solution here (these originate as simulator unit
# tests).
#
# The probable solution is to keep code signing disabled (during build), but then
# re-sign prior to running with the xctestrun file. The app, xctest, dylibs and
# frameworks need to be recursively signed. Something along the lines of:
#
# find build -name \*.framework -print0 | xargs -0 -I{} codesign --force --sign <identity> --preserve-metadata=identifier,entitlements,flags --timestamp=none {}

ENABLE_CODE_SIGNING ?= 0

# Disable code signing by default
ifeq (1,$(ENABLE_CODE_SIGNING))
CODE_SIGNING :=
else
CODE_SIGNING := CODE_SIGN_IDENTITY="" \
				CODE_SIGNING_REQUIRED=NO \
				CODE_SIGNING_ALLOWED=NO
endif

# ----------------------------------------------------------------------------------------------------------------------
# House keeping

.PHONY: clean
clean:
	-rm -rf $(BUILD_DIR)


.PHONY: distclean
distclean: clean
	-rm Package.resolved
	-rm Apps/Apps.xcworkspace/xcshareddata/swiftpm/Package.resolved
	-rm MapboxMaps.xcodeproj

$(PAYLOAD_DIR) $(TEST_ROOT) $(DEVICE_TEST_PATH):
	-mkdir -p $@

# ----------------------------------------------------------------------------------------------------------------------
# Simulators - SDK

XCODE_BUILD_SIM_SDK = set -o pipefail && xcodebuild \
	-scheme MapboxMaps \
	-sdk iphonesimulator \
	-configuration $(CONFIGURATION) \
	-jobs $(JOBS)

.PHONY: build-sdk-for-simulator
build-sdk-for-simulator:
	$(XCODE_BUILD_SIM_SDK) \
		build \
		ONLY_ACTIVE_ARCH=NO

.PHONY: build-sdk-for-testing-simulator
build-sdk-for-testing-simulator:
	$(XCODE_BUILD_SIM_SDK) \
		-destination 'platform=iOS Simulator,OS=latest,name=iPhone 11' \
		-enableCodeCoverage YES \
		build-for-testing \
		ENABLE_TESTABILITY=YES \
		ONLY_ACTIVE_ARCH=YES

.PHONY: test-sdk-without-building-simulator
test-sdk-without-building-simulator:
	$(XCODE_BUILD_SIM_SDK) \
		-destination 'platform=iOS Simulator,OS=latest,name=iPhone 11' \
		-enableCodeCoverage YES \
		test-without-building \
		ONLY_ACTIVE_ARCH=YES

# ----------------------------------------------------------------------------------------------------------------------
# Simulators - Apps

.PHONY: build-app-for-simulator
build-app-for-simulator:
	set -o pipefail && xcodebuild \
		-workspace Apps/Apps.xcworkspace \
		-scheme '$(SCHEME)' \
		-sdk iphonesimulator \
		-configuration $(CONFIGURATION) \
		-jobs $(JOBS) \
		build \
		ONLY_ACTIVE_ARCH=NO

# ----------------------------------------------------------------------------------------------------------------------
# Devices - SDK

USB_DEVICE_ID := $(strip $(shell system_profiler SPUSBDataType | sed -n -E -e "/(iPhone|iPad)/,/Serial/s/ *Serial Number: *(.+)/\1/p" ))

ifneq ($(USB_DEVICE_ID),)
USB_DEVICE_DESTINATION := -destination 'platform=ios,id=$(USB_DEVICE_ID)'
endif

# Xcode build command for building for device. The CODE_SIGNING_* variables are so that no code signing occurs on CI -
# this is because AWS Device Farm re-signs the applications. This may need to change if a different provider is used.
XCODE_BUILD_DEVICE = xcodebuild \
	$(XCODE_PROJECT) \
	-sdk iphoneos \
	-configuration $(CONFIGURATION) \
	-derivedDataPath $(BUILD_DIR) \
	-jobs $(JOBS) \
	$(CODE_SIGNING)

.PHONY: build-sdk-for-device
build-sdk-for-device:
	set -o pipefail && xcodebuild \
		-scheme MapboxMaps \
		-sdk iphoneos \
		-configuration $(CONFIGURATION) \
		-jobs $(JOBS) \
		build \
		ONLY_ACTIVE_ARCH=NO \
		$(CODE_SIGNING)

# Testing on device uses the generated `xctestrun` file that gets created. When
# testing on device, this along with the binaries are packaged into a Payload and
# sent to Device Farm. The paths have to be particular (unless the xctestrun is
# custom created). Examine the contents of the xctestrun file; __TESTROOT__ is
# the directory where the xctestrun resides.

# Example: make build-for-testing-device SCHEME=MapboxMaps
.PHONY: build-for-testing-device
build-for-testing-device: $(XCTESTRUN_PACKAGE)

$(XCODE_PROJECT_FILE): project.yml
	xcodegen

# For the moment since this PR deals with testing unit-tests on device, this target
# assumes that the tests require the "test host" app
$(XCTESTRUN_PACKAGE): $(XCODE_PROJECT_FILE) | $(PAYLOAD_DIR) $(TEST_ROOT)
ifneq ($(SCHEME),MapboxTestHost)
ifneq ($(SCHEME),Examples)
	$(error SCHEME should be MapboxTestHost or Examples)
endif
endif

	# Build for testing
	set -o pipefail && $(XCODE_BUILD_DEVICE) \
		-scheme '$(SCHEME)' \
		-enableCodeCoverage YES \
		build-for-testing \
		ENABLE_TESTABILITY=YES \
		SWIFT_TREAT_WARNINGS_AS_ERRORS=NO

	# Gather app, frameworks and xctestrun
	-mkdir $(TEST_ROOT)/$(CONFIGURATION)-iphoneos
	touch $(TEST_ROOT)/$(CONFIGURATION)-iphoneos/copy-app-and-frameworks-here

	# For use in Device Farm config
	echo $(SCHEME) > $(TEST_ROOT)/scheme.txt
	echo $(APP_NAME) > $(TEST_ROOT)/app_name.txt
	echo $(CONFIGURATION) > $(TEST_ROOT)/configuration.txt
	cp $(BUILT_DEVICE_PRODUCTS_DIR)/../$(SCHEME)_iphoneos*.xctestrun $(TEST_ROOT)/device.xctestrun

	# Package as a zip
	cd $(TEST_ROOT) && zip -r $@ -x.* .

# ----------------------------------------------------------------------------------------------------------------------
# Devices - Apps

XCODE_BUILD_DEVICE_APPS = xcodebuild \
	ONLY_ACTIVE_ARCH=NO \
	-workspace Apps/Apps.xcworkspace \
	-sdk iphoneos \
	-configuration $(CONFIGURATION) \
	-jobs $(JOBS) \
	$(CODE_SIGNING)

.PHONY: build-app-for-device
build-app-for-device:
	set -o pipefail && $(XCODE_BUILD_DEVICE_APPS) -scheme '$(SCHEME)' build

# ----------------------------------------------------------------------------------------------------------------------
# Device Farm

SHA                 := $(shell git describe --always --dirty)
BUILD_NAME          := $(SCHEME)-$(CONFIGURATION)-$(SHA)-$(CIRCLE_BUILD_NUM)

DEVICE_FARM_UPLOAD_IPA := $(BUILD_DIR)/upload.ipa
DEVICE_FARM_RUN     := $(BUILD_DIR)/$(BUILD_NAME)-run.json
DEVICE_FARM_RESULTS := $(BUILD_DIR)/$(BUILD_NAME)-results.json

# Before a device test for a scheme, we need to clear out older schemes/test-runs
# that may exist from testing a different scheme
.PHONY: clean-for-device-build
clean-for-device-build:
	-rm $(XCTESTRUN_PACKAGE)
	-rm $(DEVICE_FARM_UPLOAD_IPA)
	-rm -rf $(BUILT_DEVICE_PRODUCTS_DIR)/*.framework
	-rm -rf $(BUILT_DEVICE_PRODUCTS_DIR)/*.swiftmodule
	-rm -rf $(BUILT_DEVICE_PRODUCTS_DIR)/../*.xctestrun

# Trigger unit tests on device farm with
# This requires the following environment variables to be set (which will be on CI). The first
# two can be set by calling `mbx env`
#
#	AWS_ACCESS_KEY_ID
#	AWS_SECRET_ACCESS_KEY
#	AWS_DEVICE_FARM_PROJECT
#	AWS_DEVICE_FARM_DEVICE_POOL
#
# 	make test-with-device-farm SCHEME=MapboxTestHost APP_NAME=MapboxTestHost
#
# If token expires while the tests are in progress, run `mbx env` again followed by restarting
# the test call.

.PHONY: clean-test-with-device-farm
clean-test-with-device-farm: clean-for-device-build test-with-device-farm

.PHONY: test-with-device-farm
test-with-device-farm: $(DEVICE_FARM_RESULTS)
	python3 ./scripts/device-farm/check_results_for_failure.py $(DEVICE_FARM_RESULTS)

	# Remove the ipa
	rm $(DEVICE_FARM_UPLOAD_IPA)

# Wait for the previous scheduled run to complete and dump results/artifacts
$(DEVICE_FARM_RESULTS): $(DEVICE_FARM_RUN)
	-python3 ./scripts/device-farm/devicefarm.py \
		$(DEVICE_FARM_PROJECT) \
		--run-arn-file $(DEVICE_FARM_RUN) \
		--artifacts-dir $(DEVICE_TEST_PATH) \
		--output $(DEVICE_FARM_RESULTS)


# This should match what happens on Device Farm (except for processing of results). The devicefarm.mk makefile
# ought to match the contents of the testspec.yml file (ideally it would be shared).
#
# make local-test-with-device-farm-ipa SCHEME=MapboxTestHost APP_NAME=MapboxTestHost CONFIGURATION=Release ENABLE_CODE_SIGNING=1

.PHONY: local-test-with-device-farm-ipa
local-test-with-device-farm-ipa: $(DEVICE_FARM_UPLOAD_IPA)
ifndef USB_DEVICE_DESTINATION
	@echo "Please conntect a device via USB!"
else
	@echo "Connected to \"$(USB_DEVICE_ID)\""
	make all -f scripts/device-farm/devicefarm.mk IPA_PATH=$(DEVICE_FARM_UPLOAD_IPA) DEVICE_UDID=$(USB_DEVICE_ID) ROOT=$(BUILD_DIR)/local-run-from-ipa
endif

	# Remove the ipa
	rm $(DEVICE_FARM_UPLOAD_IPA)


# Schedule a test run on multiple devices, but don't wait for the results, just
# dump out the response from scheduling. We do this, as if you run locally the
# AWS credentials can expire, so there needs to be a mechanism to pick up from
# where we left the process.
#
# This was tried with using the APPIUM_NODE test type, but it appears that the
# app & frameworks are not re-signed. Note that we're passing the same IPA twice
# here - that's because XCTEST_UI can accept a test spec file, but needs two IPAs.

$(DEVICE_FARM_RUN): $(DEVICE_FARM_UPLOAD_IPA)
ifndef DEVICE_FARM_DEVICE_POOL
	@echo "Please define DEVICE_FARM_DEVICE_POOL"
	exit 1
else
	# Upload and start tests
	python3 ./scripts/device-farm/devicefarm.py \
		$(DEVICE_FARM_PROJECT) \
		--name $(BUILD_NAME) \
		--device-pool $(DEVICE_FARM_DEVICE_POOL) \
		--ipa $(DEVICE_FARM_UPLOAD_IPA) \
		--tests $(DEVICE_FARM_UPLOAD_IPA) \
		--spec ./scripts/device-farm/testspec.yml \
		--test-type XCTEST_UI \
		--output $(DEVICE_FARM_RUN)
endif

.PHONY: make-device-farm-ipa
make-device-farm-ipa: $(DEVICE_FARM_UPLOAD_IPA)

$(DEVICE_FARM_UPLOAD_IPA): $(XCTESTRUN_PACKAGE) | $(DEVICE_TEST_PATH) $(PAYLOAD_DIR)
	# Prepare the app
	-rm -rf $(PAYLOAD_DIR)/*

	# Creating IPA package for upload
	cp -R $(BUILT_DEVICE_PRODUCTS_DIR)/$(APP_NAME).app $(PAYLOAD_DIR)

	cp $(XCTESTRUN_PACKAGE) $(PAYLOAD_DIR)/$(APP_NAME).app/xctestrun.zip

	-rm $(DEVICE_FARM_UPLOAD_IPA)
	cd $(BUILD_DIR) && zip -r $(notdir $(DEVICE_FARM_UPLOAD_IPA)) Payload


.PHONY: gather-results
gather-results:
	python3 ./scripts/device-farm/extract-xcresult.py --artifacts-dir $(BUILD_DIR) --output-dir $(BUILD_DIR)/testruns

.PHONY: symbolicate
symbolicate:
	@echo Symbolicating crash reports

	@export DEVELOPER_DIR=$$(xcode-select -p); \
	CRASHES=`find $(DEVICE_TEST_PATH) -name Application_Crash_Report.ips` ; \
	for CRASH in $${CRASHES[@]} ; \
	do \
		if [ ! -f $${CRASH}.symbolicated.txt ]; then \
			echo "Symbolicating $${CRASH}" ; \
			$${DEVELOPER_DIR}/Platforms/MacOSX.platform/Developer/iOSSupport/Library/PrivateFrameworks/DVTFoundation.framework/Versions/A/Resources/symbolicatecrash \
				$${CRASH} \
				$(BUILT_DEVICE_PRODUCTS_DIR)/$(APP_NAME).app/ \
				$(BUILT_DEVICE_PRODUCTS_DIR)/$(APP_NAME).app/Frameworks/ \
				$(BUILT_DEVICE_PRODUCTS_DIR)/$(APP_NAME).app/Plugins/ \
				-o $${CRASH}.symbolicated.txt ; \
			cat $${CRASH}.symbolicated.txt ; \
		fi ; \
	done


# Codecov.io appears to struggle with the raw coverage data from Xcode (in this Device Farm testing scenario).
# Explicitly converting it to an lcov format helps.
#
# However, the following conversion of the profdata has failed once. If this continues to be an
# issue, it will be worth trying the following first:
#
# xcrun llvm-profdata merge -o dest.profdata source.profraw
#

# Root directory in which to search for "profdata" coverage files, from which we generate
# the lcov data (both lcov and json formats)
COVERAGE_ROOT_DIR ?= $(BUILD_DIR)/Build/ProfileData
COVERAGE_MAPBOX_MAPS ?= $(BUILD_DIR)/Build/Products/$(CONFIGURATION)-iphonesimulator/MapboxMaps.o
COVERAGE_ARCH ?= x86_64

# .PHONY: update-codecov-with-profdata
# update-codecov-with-profdata:
# 	curl -sSfL --retry 5 --connect-timeout 5 https://codecov.io/bash > /tmp/codecov.sh
# 	@PROF_DATA=`find $(COVERAGE_ROOT_DIR) -regex '.*\.profraw'` ; \
# 	for RESULT in $${PROF_DATA[@]} ; \
# 	do \
# 		echo "Generating $${RESULT}.lcov" ; \
# 		xcrun llvm-profdata merge -o $${RESULT}.profdata $${RESULT} ; \
# 		xcrun llvm-cov export \
# 			$(COVERAGE_MAPBOX_MAPS) \
# 			-instr-profile=$${RESULT}.profdata \
# 			-arch=$(COVERAGE_ARCH) \
# 			-format=lcov > $${RESULT}.lcov ; \
# 		echo "Uploading $${RESULT}.lcov to CodeCov.io" ; \
# 		bash /tmp/codecov.sh \
# 			-f $${RESULT}.lcov \
# 			-t $(CODECOV_TOKEN) \
# 			-J '^MapboxMaps$$' \
# 			-n $${RESULT}.lcov \
# 			-F "$$(echo '$(SCHEME)' | sed 's/[[:upper:]]/_&/g;s/^_//' | tr '[:upper:]' '[:lower:]')" ; \
# 		echo "Generating lcov JSON" ; \
# 		xcrun llvm-cov export \
# 			$(COVERAGE_MAPBOX_MAPS) \
# 			-instr-profile=$${RESULT}.profdata \
# 			-arch=$(COVERAGE_ARCH) \
# 			-format=text | python3 -m json.tool > $${RESULT}.json ; \
# 		echo "Uploading to S3" ; \
# 		python3 ./scripts/code-coverage/parse-code-coverage.py \
# 			-g . \
# 			-c MapboxMaps \
# 			--scheme $(SCHEME) \
# 			--report $${RESULT}.json ; \
# 	done
# 	@echo "Done"

.PHONY: update-codecov-with-profdata
update-codecov-with-profdata:
	@PROF_DATA=`find $(COVERAGE_ROOT_DIR) -regex '.*\.profdata'` ; \
	for RESULT in $${PROF_DATA[@]} ; \
	do \
		echo "Generating lcov JSON" ; \
		xcrun llvm-cov export \
			$(COVERAGE_MAPBOX_MAPS) \
			-instr-profile=$${RESULT} \
			-arch=$(COVERAGE_ARCH) \
			-format=text | python3 -m json.tool > $${RESULT}.json ; \
		echo "Uploading to S3" ; \
		python3 ./scripts/code-coverage/parse-code-coverage.py \
			-g . \
			-c MapboxMaps \
			--scheme $(SCHEME) \
			--report $${RESULT}.json ; \
	done
	@echo "Done"

.PHONY: device-update-codecov-with-profdata
device-update-codecov-with-profdata:
	make update-codecov-with-profdata \
		COVERAGE_ARCH=arm64 \
		COVERAGE_ROOT_DIR=$(BUILD_DIR)/testruns \
		COVERAGE_MAPBOX_MAPS='$(BUILT_DEVICE_PRODUCTS_DIR)/MapboxMaps.o'

# ----------------------------------------------------------------------------------------------------------------------
# Dependencies

.PHONY: install-devicefarm-dependencies
install-devicefarm-dependencies:
	brew install jq
	pip3 install awscli requests

$(NETRC_FILE):
ifndef SDK_REGISTRY_TOKEN
	@echo SDK_REGISTRY_TOKEN not set.
	exit 1
endif
	@echo "$$NETRC" > $(NETRC_FILE)

# ----------------------------------------------------------------------------------------------------------------------
# Validation

# See https://circleci.com/blog/circleci-hacks-validate-circleci-config-on-every-commit-with-a-git-hook/ for installing
# a pre commit hook to validate the CircleCI config. Call `make validate` from the pre-commit script.
.PHONY: validate
validate: $(CIRCLE_CI_CLI)
	$(CIRCLE_CI_CLI) config validate -c .circleci/config.yml

$(CIRCLE_CI_CLI):
	curl -fLSs https://circle.ci/cli | bash
