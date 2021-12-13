fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew install fastlane`

# Available Actions
## iOS
### ios beta
```
fastlane ios beta
```

### ios build_and_submit
```
fastlane ios build_and_submit
```
Submit a new Beta Build to Apple TestFlight

This will also make sure that the signing certificate and provisioning profiles are up to date.
### ios deploy_to_testflight
```
fastlane ios deploy_to_testflight
```
Build and submit a new beta build to Apple TestFlight.

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
