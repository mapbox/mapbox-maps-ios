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
CIRCLE_CI_CLI       ?= /tmp/circleci

# Derived variables
BUILT_DEVICE_PRODUCTS_DIR := $(BUILD_DIR)/Build/Products/$(CONFIGURATION)-iphoneos
TEST_ROOT                 := $(BUILD_DIR)/test-root
PAYLOAD_DIR               := $(BUILD_DIR)/Payload

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

$(PAYLOAD_DIR) $(TEST_ROOT):
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
		-destination 'platform=iOS Simulator,OS=latest,name=iPhone 11' \
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
		-resultBundlePath MapboxMapsTests.xcresult \
		ONLY_ACTIVE_ARCH=YES

# ----------------------------------------------------------------------------------------------------------------------
# Simulators - Apps

.PHONY: build-app-for-simulator
build-app-for-simulator:
	set -o pipefail && xcodebuild \
		-workspace Apps/Apps.xcworkspace \
		-scheme '$(SCHEME)' \
		-sdk iphonesimulator \
		-destination 'platform=iOS Simulator,OS=latest,name=iPhone 11' \
		-configuration $(CONFIGURATION) \
		-jobs $(JOBS) \
		build \
		ONLY_ACTIVE_ARCH=NO

# ----------------------------------------------------------------------------------------------------------------------
# Devices - SDK

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
		-destination 'generic/platform=iOS' \
		-configuration $(CONFIGURATION) \
		-jobs $(JOBS) \
		build \
		ONLY_ACTIVE_ARCH=NO \
		$(CODE_SIGNING)

$(XCODE_PROJECT_FILE): project.yml
	xcodegen

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
# Symbolication

.PHONY: symbolicate
symbolicate:
	@echo Symbolicating crash reports

	@export DEVELOPER_DIR=$$(xcode-select -p); \
	CRASHES=`find $(BUILD_DIR) -name *.ips` ; \
	echo "crashes: $${CRASHES}"; \
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
		COVERAGE_ROOT_DIR=$(BUILD_DIR)/ \
		COVERAGE_MAPBOX_MAPS='$(BUILT_DEVICE_PRODUCTS_DIR)/MapboxMaps.o'

# ----------------------------------------------------------------------------------------------------------------------
# Dependencies

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
	curl -fLSs https://circle.ci/cli | DESTDIR=/tmp bash
