# ----------------------------------------------------------------------------------------------------------------------
# Configurable varibles
XCODE_WORKSPACE ?= MapboxMaps.xcworkspace

# Default to Debug since Release will require testability. (See #157)
CONFIGURATION    ?= Debug
BUILD_DIR        ?= $(CURDIR)/build
JOBS             ?= $(shell sysctl -n hw.ncpu)
DESTINATIONS     ?= -destination 'platform=iOS Simulator,OS=latest,name=iPhone 11'
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
BUILT_XCFRAMEWORK_PATH	  := $(BUILD_DIR)/Build/Products/XCFramework/MapboxMaps.xcframework

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
	-rm Cartfile.resolved
	-rm -rf Carthage \
			~/Library/Caches/carthage \
			~/Library/Caches/org.carthage.kit

$(PAYLOAD_DIR) $(TEST_ROOT) $(DEVICE_TEST_PATH):
	-mkdir -p $@

# ----------------------------------------------------------------------------------------------------------------------
# Simulators

# x86_64 because CMapbox doesn't have i386 currently
XCODE_BUILD_SIM = xcodebuild \
	ARCHS=x86_64 \
	ONLY_ACTIVE_ARCH=YES \
	-workspace $(XCODE_WORKSPACE) \
	-sdk iphonesimulator \
	-configuration $(CONFIGURATION) \
	-derivedDataPath $(BUILD_DIR) \
	-jobs $(JOBS)

.PHONY: build-for-simulator
build-for-simulator:
	set -o pipefail && $(XCODE_BUILD_SIM) -scheme '$(SCHEME)' build

.PHONY: build-for-testing-simulator
build-for-testing-simulator:
	set -o pipefail && $(XCODE_BUILD_SIM) -scheme '$(SCHEME)' ENABLE_TESTABILITY=YES build-for-testing -enableCodeCoverage YES

.PHONY: test-without-building-simulator
test-without-building-simulator:
	set -o pipefail && $(XCODE_BUILD_SIM) -scheme '$(SCHEME)' $(DESTINATIONS) test-without-building -enableCodeCoverage YES

# ----------------------------------------------------------------------------------------------------------------------
# Devices

USB_DEVICE_ID := $(strip $(shell system_profiler SPUSBDataType | sed -n -E -e "/(iPhone|iPad)/,/Serial/s/ *Serial Number: *(.+)/\1/p" ))

ifneq ($(USB_DEVICE_ID),)
USB_DEVICE_DESTINATION := -destination 'platform=ios,id=$(USB_DEVICE_ID)'
endif

# Xcode build command for building for device. The CODE_SIGNING_* variables are so that no code signing occurs on CI - 
# this is because AWS Device Farm re-signs the applications. This may need to change if a different provider is used.
XCODE_BUILD_DEVICE = xcodebuild \
	-workspace $(XCODE_WORKSPACE) \
	-sdk iphoneos \
	-configuration $(CONFIGURATION) \
	-derivedDataPath $(BUILD_DIR) \
	-jobs $(JOBS) \
	$(CODE_SIGNING)

.PHONY: build-for-device
build-for-device:
	set -o pipefail && $(XCODE_BUILD_DEVICE) -scheme '$(SCHEME)' build 

# Testing on device uses the generated `xctestrun` file that gets created. When
# testing on device, this along with the binaries are packaged into a Payload and
# sent to Device Farm. The paths have to be particular (unless the xctestrun is 
# custom created). Examine the contents of the xctestrun file; __TESTROOT__ is
# the directory where the xctestrun resides.

# Example: make build-for-testing-device SCHEME=MapboxMaps
.PHONY: build-for-testing-device
build-for-testing-device: $(XCTESTRUN_PACKAGE)

# For the moment since this PR deals with testing unit-tests on device, this target
# assumes that the tests require the "test host" app
$(XCTESTRUN_PACKAGE): | $(PAYLOAD_DIR) $(TEST_ROOT)
ifneq ($(SCHEME),MapboxMapsTestsWithHost)
ifneq ($(SCHEME),Examples)
	$(error SCHEME should be MapboxMapsTestsWithHost or Examples)
endif
endif

	# Build for testing
	set -o pipefail && $(XCODE_BUILD_DEVICE) \
		-scheme '$(SCHEME)' \
		-xcconfig $(CURDIR)/Mapbox/Configurations/$(APP_NAME)_testhost.xcconfig \
		-enableCodeCoverage YES \
		build-for-testing 

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
# Device Farm

SHA                 := $(shell git describe --always --dirty)
BUILD_NAME          := $(SCHEME)-$(CONFIGURATION)-$(SHA)-$(CIRCLE_BUILD_NUM)

DEVICE_FARM_UPLOAD_IPA := $(BUILD_DIR)/upload.ipa
DEVICE_FARM_RUN     := $(BUILD_DIR)/$(BUILD_NAME)-run.json
DEVICE_FARM_RESULTS := $(BUILD_DIR)/$(BUILD_NAME)-results.json

.PHONY: check_aws_creds
check_aws_creds:
ifndef AWS_ACCESS_KEY_ID 
	@echo AWS_ACCESS_KEY_ID not set.
	exit 1
endif
ifndef AWS_SECRET_ACCESS_KEY
	@echo AWS_SECRET_ACCESS_KEY not set.
	exit 1
endif
ifndef AWS_DEVICE_FARM_PROJECT
	@echo AWS_DEVICE_FARM_PROJECT not set.
	exit 1
endif

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
# 	make test-with-device-farm SCHEME=MapboxMapsTestsWithHost APP_NAME=MapboxTestHost 
# 
# If token expires while the tests are in progress, run `mbx env` again followed by restarting
# the test call. 

.PHONY: clean-test-with-device-farm
clean-test-with-device-farm: clean-for-device-build test-with-device-farm

.PHONY: test-with-device-farm
test-with-device-farm: check_aws_creds $(DEVICE_FARM_RESULTS)
	python3 ./scripts/device-farm/check_results_for_failure.py $(DEVICE_FARM_RESULTS)

	# Remove the ipa
	rm $(DEVICE_FARM_UPLOAD_IPA)

# Wait for the previous scheduled run to complete and dump results/artifacts
$(DEVICE_FARM_RESULTS): $(DEVICE_FARM_RUN)
	-python3 ./scripts/device-farm/devicefarm.py \
		$(AWS_DEVICE_FARM_PROJECT) \
		--run-arn-file $(DEVICE_FARM_RUN) \
		--artifacts-dir $(DEVICE_TEST_PATH) \
		--output $(DEVICE_FARM_RESULTS)


# This should match what happens on Device Farm (except for processing of results). The devicefarm.mk makefile
# ought to match the contents of the testspec.yml file (ideally it would be shared).
#
# make local-test-with-device-farm-ipa SCHEME=MapboxMapsTestsWithHost APP_NAME=MapboxTestHost CONFIGURATION=Release ENABLE_CODE_SIGNING=1

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
ifndef AWS_DEVICE_FARM_DEVICE_POOL
	@echo "Please define AWS_DEVICE_FARM_DEVICE_POOL"
	exit 1
else	
	# Upload and start tests
	python3 ./scripts/device-farm/devicefarm.py \
		$(AWS_DEVICE_FARM_PROJECT) \
		--name $(BUILD_NAME) \
		--device-pool $(AWS_DEVICE_FARM_DEVICE_POOL) \
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
	python3 ./scripts/device-farm/extract-xcresult.py --outdir $(BUILD_DIR)/testruns

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
COVERAGE_MAPBOX_MAPS ?= $(BUILD_DIR)/Build/Products/$(CONFIGURATION)-iphonesimulator/MapboxMaps.framework/MapboxMaps
COVERAGE_ARCH ?= x86_64

.PHONY: update-codecov-with-profdata device-update-codecov-with-profdata
update-codecov-with-profdata:
	curl -sSfL --retry 5 --connect-timeout 5 https://codecov.io/bash > /tmp/codecov.sh
	@PROF_DATA=`find $(COVERAGE_ROOT_DIR) -regex '.*\.profraw'` ; \
	for RESULT in $${PROF_DATA[@]} ; \
	do \
		echo "Generating $${RESULT}.lcov" ; \
		xcrun llvm-profdata merge -o $${RESULT}.profdata $${RESULT} ; \
		xcrun llvm-cov export \
			$(COVERAGE_MAPBOX_MAPS) \
			-instr-profile=$${RESULT}.profdata \
			-arch=$(COVERAGE_ARCH) \
			-format=lcov > $${RESULT}.lcov ; \
		echo "Uploading $${RESULT}.lcov to CodeCov.io" ; \
		bash /tmp/codecov.sh \
			-f $${RESULT}.lcov \
			-t $(CODECOV_TOKEN) \
			-J '^MapboxMaps$$' \
			-n $${RESULT}.lcov \
			-F $(SCHEME) ; \
		echo "Generating lcov JSON" ; \
		xcrun llvm-cov export \
			$(COVERAGE_MAPBOX_MAPS) \
			-instr-profile=$${RESULT}.profdata \
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

device-update-codecov-with-profdata:
	make update-codecov-with-profdata \
		COVERAGE_ARCH=arm64 \
		COVERAGE_ROOT_DIR=$(BUILD_DIR)/testruns \
		COVERAGE_MAPBOX_MAPS=$(BUILT_DEVICE_PRODUCTS_DIR)/MapboxMaps.framework/MapboxMaps

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

.PHONY: deps
deps: | $(NETRC_FILE)
	XCODE_XCCONFIG_FILE=${PWD}/xcode-12.xcconfig carthage bootstrap --platform iOS --use-netrc --no-cache-builds

# ----------------------------------------------------------------------------------------------------------------------
# Validation

# See https://circleci.com/blog/circleci-hacks-validate-circleci-config-on-every-commit-with-a-git-hook/ for installing
# a pre commit hook to validate the CircleCI config. Call `make validate` from the pre-commit script.
.PHONY: validate
validate: $(CIRCLE_CI_CLI)
	$(CIRCLE_CI_CLI) config validate -c .circleci/config.yml 

$(CIRCLE_CI_CLI):
	curl -fLSs https://circle.ci/cli | bash


# # ----------------------------------------------------------------------------------------------------------------------
# Create an XCFramework

XCODE_ARCHIVE_SIM = xcodebuild archive \
	-workspace $(XCODE_WORKSPACE) \
	-scheme MapboxMaps \
	-destination="iOS Simulator" \
	-archivePath /tmp/xcf/iossimulator.xcarchive \
	-derivedDataPath /tmp/iphoneos \
	-sdk iphonesimulator \
	SKIP_INSTALL=NO \
	BUILD_LIBRARIES_FOR_DISTRIBUTION=YES 

XCODE_ARCHIVE_DEVICE = xcodebuild archive \
	-workspace $(XCODE_WORKSPACE) \
	-scheme MapboxMaps \
	-destination="iOS" \
	-archivePath /tmp/xcf/ios.xcarchive \
	-derivedDataPath /tmp/iphoneos \
	-sdk iphoneos \
	SKIP_INSTALL=NO \
	BUILD_LIBRARIES_FOR_DISTRIBUTION=YES \
	$(CODE_SIGNING)

XCODE_CREATE_XCFRAMEWORK = xcodebuild \
	-create-xcframework \
	-framework /tmp/xcf/ios.xcarchive/Products/Library/Frameworks/MapboxMaps.framework \
	-framework /tmp/xcf/iossimulator.xcarchive/Products/Library/Frameworks/MapboxMaps.framework \
	-output $(BUILT_XCFRAMEWORK_PATH)

.PHONY: xcframework
xcframework:
	set -o pipefail && $(XCODE_ARCHIVE_SIM) && $(XCODE_ARCHIVE_DEVICE) && $(XCODE_CREATE_XCFRAMEWORK)
