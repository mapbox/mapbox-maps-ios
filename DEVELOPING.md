# Developing

This guide contains the steps required to contribute to the development of this project.

* [Setting Up a Development Environment](#setting-up-a-development-environment)
* [Updating Dependency Versions](#updating-dependency-versions)
* [Running Unit Tests On Devices](#running-unit-tests-on-devices)
* [Running Integration Tests](#running-integration-tests)
* [Making an Example](#making-an-example)

## Setting Up a Development Environment

This project runs on Apple's Metal rendering framework. Prerequisites for
running the test app in simulators:

* macOS 10.15 or later
* Xcode 12.5.1+

This project:

1. requires a valid ~/.netrc file with a Mapbox [**secret token**](https://docs.mapbox.com/help/dive-deeper/access-tokens/#secret-tokens) to download binary dependencies.
  **Note**: A public token (pk.*) is not sufficient for downloading binary dependencies.

2. reads a Mapbox access token from a [file at `~/mapbox`](https://docs.mapbox.com/help/troubleshooting/private-access-token-android-and-ios/#ios)
   to enable tests and apps to access Mapbox APIs.

3. uses [SwiftLint](https://github.com/realm/SwiftLint) to enforce a style
   guide. Install it with `brew install swiftlint` and check for lint by running
   `swiftlint` in the root of the repository.

4. uses [Swift Package Manager](https://github.com/apple/swift-package-manager)
   to manage dependencies for development. CocoaPods is supported for *consuming*
   the SDK.

5. uses [Carthage](https://github.com/Carthage/Carthage) to manage binary dependencies that are automatically downloaded when running xcodegen.

6. Install pre-commit hooks
  ```bash
  brew install xcodegen swiftlint carthage
  pip install pre-commit

  pre-commit install # Installs the pre-commit hooks
  ```

7. uses CircleCI and Firebase Test Lab for continuous integration.

### Accessing the Maps SDK's Source

Clone the git repository:

```sh
git clone git@github.com:mapbox/mapbox-maps-ios.git && cd mapbox-maps-ios
```

### Building the Maps SDK

* Run `xcodegen` in the root of the repo to generate the Xcode project.
* Open the resulting `MapboxMaps.xcodeproj` in Xcode and and build the `MapboxMaps` target.

### Running the Debug App

In order to use the debug app, run the `DebugApp` scheme.

## Updating Dependency Versions

* Update the dependency versions in `Package.swift`
* Open `Package.swift` in Xcode and resolve dependencies. This updates
  `Package.resolved`. Close that Xcode workspace.
* Open `Apps/Apps.xcworkspace` in Xcode and resolve dependencies. This updates
  a different `Package.resolved` file in the `Apps.workspace` bundle. Close that
  Xcode workspace.
* Update the dependency versions in `MapboxMaps.podspec`
* Update the dependency versions in `scripts/release/packager/versions.json`

## Running Unit Tests On Devices locally

   * Follow the [Building the Maps SDK](#building-the-maps-sdk) steps above.
   * Test the `MapboxTestHost` scheme.

## Running Integration Tests

Integration tests typically require a Metal device, so these tests can only run
locally and on Firebase Test Lab. They are skipped when running on CI
inside of a VM and when running on simulators < iOS 13 (iOS 13+ has a simulated
Metal device.)

### What happens if I run integration tests via `MapboxTestHost`?

There **is** a host application, so `MapViewIntegrationTestCase` fetches the
existing window and view controller before adding the MapView to it.

* These tests can be run on devices.
* Tests will be skipped on simulators < iOS 13

### What happens if I run integration tests via `MapboxMaps`

There is **no host application**, so `MapViewIntegrationTestCase` creates its
own `UIWindow` and root view controller, before adding the MapView to it.

* These tests cannot be run on devices.
* Tests will be skipped on simulators < iOS 13
* Tests will be skipped entirely on CircleCI because of the VM (no Metal).

### Base classes

* `IntegrationTestCase` is a base class that fetches the access token for use in
  tests. It checks for the token in the following locations and uses the first
  one that it finds:
  * `UserDefaults` under the key `MBXAccessToken`. This allows setting a value
    when running tests from the command line.
  * `Info.plist` under the key `MBXAccessToken`. The value for this key is
    populated automatically when running tests via `MapboxTestHost` if you have
    a `developer.xcconfig` file in the root of the repo that looks like:

    ```Text
    MAPBOX_ACCESS_TOKEN = pk.myaccesstoken
    ```

  * a resource in the test bundle named MapboxAccessToken. This file is
    generated at build time via a pre-action on the scheme when running tests
    using `MapboxMaps`. The pre-action pulls the token from `~/mapbox` or `~/.mapbox`.

* `MapViewIntegrationTestCase` subclasses the above, and sets the `MapView`.
  Closures are used to expose key map events to subclasses. Please don't add
  tests to this class.

* `ExampleIntegrationTest` is an example of using the above, that sets a style
  then waits for the load to finish.

## Making an Example

* Check out this [project](https://github.com/mapbox/mapbox-maps-ios/blob/main/Examples.xcodeproj)
  to get more information about adding examples to our project.

## Tracing map performance

Internal events of MapboxMaps can captured in Xcode Instruments using [signposts](https://developer.apple.com/documentation/os/logging/recording_performance_data). Most useful examples of them:
- Rendering calls
- Gestures points of interests

In order to enable them, set `MAPBOX_MAPS_SIGNPOSTS_ENABLED` environment variable to your Profile Scheme.
