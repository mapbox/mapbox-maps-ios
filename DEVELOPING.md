# Developing

This guide contains the steps required to contribute to the development of this project.

  * [Setting up a development environment](#setting-up-a-development-environment)
  * [Building the Maps SDK](#building-the-maps-sdk)
  * [Update dependency versions](#update-dependency-versions)
  * [Running the Debug app](#running-the-debug-app)
  * [CircleCI](#circleci)
  * [Unit testing on devices](#unit-testing-on-devices)
  * [Integration tests](#integration-tests)
  * [Making an example](#making-an-example)

## Setting up a development environment

This project runs on Apple's Metal rendering framework. Prerequisites for running the test app in simulators:

- macOS 10.15 or later
- Xcode 12.5.1+

This project:

1. requires [a valid ~/.netrc file](https://docs.mapbox.com/ios/maps/guides/install/#configure-credentials) to fetch dependencies.

2. uses [SwiftLint](https://github.com/realm/SwiftLint) to enforce a style guide. Install it with `brew install swiftlint` and check for lint by running `swiftlint` in the root of the repository.

3. uses [Swift Package Manager](https://github.com/apple/swift-package-manager) to manage dependencies for development. Cocapods is supported for *consuming* the SDK.

4. uses [secret-shield](https://github.com/mapbox/secret-shield) to help block secrets such as access tokens from being exposed. Setup `secret-shield` by running:
```
npm install -g @mapbox/secret-shield
scripts/install-pre-commit/install-pre-commit.sh
```

5. uses CircleCI and Firebase Test Lab for continuous integration.

### Accessing the Maps SDK's source

Clone the git repository:

```
git clone git@github.com:mapbox/mapbox-maps-ios.git && cd mapbox-maps-ios
```

## Building the Maps SDK

Pre-requisite: Valid `.netrc` file located on your machine at `~/.netrc`. This allows Swift Package Manager to download binary dependencies from Mapbox. Please visit https://docs.mapbox.com/ios/maps/overview for additional information about setting up your `.netrc` file.

Open `Package.swift` and build the MapboxMaps target.

## Update dependency versions

- Update the dependency versions in Package.swift
- Open Package.swift in Xcode and resolve dependencies. This updates Package.resolved. Close that Xcode workspace.
- Open Apps/Apps.xcworkspace in Xcode and resolve dependencies. This updates a different Package.resolved file in the Apps.workspace bundle. Close that Xcode workspace.
- Update the dependency versions in MapboxMaps.podspec
- Update the dependency versions in scripts/release/packager/versions.json

## Running the Debug App

In order to use the debug app, open Apps/Apps.xcworkspace and build and run the `DebugApp` scheme.

You must provide a Mapbox access token to display Mapbox-hosted maps in the `DebugApp` test application. Add your Mapbox token to the `MBXAccessToken` key in `DebugApp/DebugApp/Info.plist`. Alternatively, create a [file at `~/mapbox`](https://docs.mapbox.com/help/troubleshooting/private-access-token-android-and-ios/#ios) containing your access token.

## CircleCI

You can run `make validate` to ensure you've formatted the changes to the CircleCI config file correctly. This make target will install the [CircleCI command line interface](https://circleci.com/docs/2.0/local-cli/) to validate `.circleci/config.yml`, and run `circleci config validate`.

## Unit Testing on devices

To run device tests there are few options:

1. Run locally:
  - Install [xcodegen](https://github.com/yonaskolb/XcodeGen).
  - Run `$ xcodegen` in the root of the repo.
  - Open the resulting `MapboxMaps.xcodeproj`.
  - Test (Cmd-U) the `MapboxTestHost` scheme.
2. Run in CI:
  - Open the optional-tests workflow for your branch in CircleCI
  - Approve the `run-tests?` job to trigger running unit tests on Firebase Test Lab
  - Approve the `run-examples-tests?` job to trigger running examples tests on Firebase Test Lab

## Integration Tests

Integration tests typically require a Metal device, so these tests can only run locally and on Firebase Test Lab. They are skipped when running on CircleCI inside of a VM and when running on simulators < iOS 13 (iOS 13+ has a simulated Metal device.)

### What happens if I run integration tests via `MapboxTestHost`?

There **is** a host application, so `MapViewIntegrationTestCase` fetches the existing window and view controller before adding the MapView to it.

- These tests can be run on devices.
- Tests will be skipped on simulators < iOS 13 

### What happens if I run integration tests via `MapboxMaps`

There is **no host application**, so `MapViewIntegrationTestCase` creates its own `UIWindow` and root view controller, before adding the MapView to it.

- These tests cannot be run on devices.
- Tests will be skipped on simulators < iOS 13 
- Tests will be skipped entirely on CircleCI because of the VM (no Metal).

### Base classes

- `IntegrationTestCase` is a base class that fetches the access token either from the Info.plist or from `UserDefaults` (which will override). The Info.plist in `MapboxMaps` has been set up to use the variable `MAPBOX_ACCESS_TOKEN`. **Please add a `developer.xcconfig` in the root of the repo, that looks like:**

    ```
    MAPBOX_ACCESS_TOKEN = pk.myaccesstoken
    ```

    The CircleCI config file has been set up to create this.

- `MapViewIntegrationTestCase` subclasses the above, and sets the `MapView`. Closures are used to expose key map events to subclasses. Please don't add tests to this class.

- `ExampleIntegrationTest` is an example of using the above, that sets a style then waits for the load to finish.

## Making an Example

* Check out this [doc](https://github.com/mapbox/mapbox-maps-ios/blob/main/Apps/Examples/README.md) to get more information about adding examples to our project.
