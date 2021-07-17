# Developing

This guide contains the steps required to contribute to the development of this project.

### Setting up a development environment

This project runs on Apple's Metal rendering framework. Prerequisites for running the test app in simulators:

- macOS 10.15 or later
- Xcode 12.2+

This project:

1. requires [a valid ~/.netrc file](https://docs.mapbox.com/ios/maps/guides/install/#configure-credentials) to fetch dependencies.

2. uses [SwiftLint](https://github.com/realm/SwiftLint) to enforce a style guide. Install it with `brew install swiftlint` and check for lint by running `swiftlint` in the root of the repository.

3. uses [Swift Package Manager](https://github.com/apple/swift-package-manager) to manage dependencies for development. Cocapods is supported for *consuming* the SDK.

4. uses [secret-shield](https://github.com/mapbox/secret-shield) to help block secrets such as access tokens from being exposed. Install `secret-shield` by entering `npm install -g @mapbox/secret-shield`. Install the pre-commit hook by running `scripts/install-pre-commit/install-pre-commit.sh`

5. uses CircleCI and AWS Device Farm for continuous integration.

### Accessing the Maps SDK's source

Clone the git repository:

```
git clone git@github.com:mapbox/mapbox-maps-ios.git && cd mapbox-maps-ios
```

### Building the Maps SDK

Pre-requisite: Valid `.netrc` file located on your machine at `~/.netrc`. Please visit https://docs.mapbox.com/ios/maps/overview for additional information about setting up your `.netrc` file.

Open `Package.swift` and build the MapboxMaps target.

### Running the Debug App

In order to use the debug app, open Apps/Apps.xcworkspace and build and run the `DebugApp` target.

You must provide a Mapbox access token to display Mapbox-hosted maps in the `DebugApp` test application. Add your Mapbox token to the `MBXAccessToken` key in `DebugApp/DebugApp/Info.plist`. Alternatively, create a [file at `~/mapbox`](https://docs.mapbox.com/help/troubleshooting/private-access-token-android-and-ios/#ios) containing your access token.

### CircleCI

CircleCI's [YAML](https://en.wikipedia.org/wiki/YAML) format can be picky. You can run `make validate` to ensure you've formatted the changes to the config file correctly. This make target will install the [CircleCI command line interface](https://circleci.com/docs/2.0/local-cli/) to validate `.circleci/config.yml`, and run `circleci config validate`

## Testing

## Unit Testing on devices

To run device tests there are few options:

1. Run via Xcode:

  - Install [xcodegen](https://github.com/yonaskolb/XcodeGen).
  - Run `$ xcodegen` in the root of the repo.
  - Open the resulting `MapboxMaps.xcodeproj`.
  - Test (Cmd-U) the `MapboxTestHost` scheme.

2. Trigger via CI by adding `[run device tests]` to a git commit message. These tests also run "nightly". 
(Examples can also be run as tests on CI by adding `[run app device tests]`.)

3. Trigger tests on AWS Device Farm from the command line by running `make test-with-device-farm SCHEME=MapboxTestHost APP_NAME=MapboxTestHost`. This requires certain environment variables to be set; please see the makefile for these.

4. Trigger tests on a local device (connected by USB) using the same setup as Device Farm testing by running:
`make local-test-with-device-farm-ipa SCHEME=MapboxTestHost CONFIGURATION=Release ENABLE_CODE_SIGNING=1`

## Integration Tests

Integration tests typically test the integration between components. As such most will require a `MapView`. These can be run locally and on AWS Device Farm.

Since these tests require a map view, they also need a `UIWindow` and Metal rendering to work. For both testing scenarios, if there's no valid Metal device the test will be skipped (i.e. not failure/success).

### What happens if I run from `MapboxTestHost`?

There **is** a host application, so `MapViewIntegrationTestCase` fetches the existing window and view controller before adding the MapView to it.

- These tests can be run on devices.
- Tests will be skipped on simulators < iOS 13 because there's no valid Metal device. (iOS 13+ has a simulated Metal device.)

### What happens if I run from `MapboxMaps`

There is **no host application**, so `MapViewIntegrationTestCase` creates its own `UIWindow` and root view controller, before adding the MapView to it.

- These tests cannot be run on devices.
- Tests will be skipped on simulators < iOS 13 because there's no valid Metal device.
- Tests will be skipped entirely on CircleCI because of the VM (no Metal). **So for CI purposes, integration tests should be run on AWS Device Farm via `MapboxTestHost`**

As you can see the most useful case is to run within from the host application. Be aware that this has the potential for side-effects, since the application is not restarted for each test.

### Base classes

- `IntegrationTestCase` is a base class that fetches the access token either from the Info.plist or from `UserDefaults` (which will override). The Info.plist in `MapboxMaps` has been set up to use the variable `MAPBOX_ACCESS_TOKEN`. **Please add a `developer.xcconfig` in the root of the repo, that looks like:**

    ```
    MAPBOX_ACCESS_TOKEN = pk.myaccesstoken
    ```

    The CircleCI config file has been set up to create this.

- `MapViewIntegrationTestCase` subclasses the above, and sets the `MapView`, and is the `MBXMapViewDelegate`. Closures are used to expose these callbacks to subclasses. Please don't add tests to this class.

- `ExampleIntegrationTest` is an example of using the above, that sets a style then waits for the load to finish.

## Application Testing

### Making an Example

* Check out this [doc](https://github.com/mapbox/mapbox-maps-ios/blob/main/Apps/Examples/README.md) to get more information about adding examples to our project.