# Developing

This guide contains the steps required to contribute to the development of this project.

### Setting up a development environment

This project runs on Apple's Metal rendering framework. Prerequisites for running the test app in simulators:
- macOS 10.15 or later
- Xcode 12.2. There is a known issue with Xcode 12.3 and later, and as such are not currently supported.
- Swift 5.3 (this is the default)

This project requires Carthage v0.35.0 or later (and [a valid ~/.netrc file](https://docs.mapbox.com/ios/maps/guides/install/#configure-credentials)) to fetch dependencies.

This project uses [SwiftLint](https://github.com/realm/SwiftLint) to enforce a style guide. Make sure you have this installed with `brew install swiftlint` before running in Xcode, otherwise you'll get an error. 

This project uses [secret-shield](https://github.com/mapbox/secret-shield) to help block secrets such as access tokens from being exposed. Install `secret-shield` by entering `npm install -g @mapbox/secret-shield`. Install the pre-commit hook by running `scripts/install-pre-commit/install-pre-commit.sh`

### Accessing the Maps SDK's source

Clone the git repository:

```
git clone git@github.com:mapbox/mapbox-maps-ios.git && cd mapbox-maps-ios
```

### Building the Maps SDK

Pre-requisite: Valid `.netrc` file located on your machine at `~/.netrc`. Please visit https://docs.mapbox.com/ios/maps/overview for additional information about setting up your `.netrc` file. 

After cloning the repo, run `make deps` from the root folder to initialize the project's dependencies.

Once complete, you can open `MapboxMaps.xcworkspace` and build any of the targets.
In order to use the test app, build and run the `DebugApp` target.

### Configuring the Maps SDK

You must provide a Mapbox access token to display Mapbox-hosted maps in the `DebugApp` test application. Add your Mapbox token to the `MBXAccessToken` key in `DebugApp/DebugApp/Info.plist`. Alternatively, create a [file at `~/mapbox`](https://docs.mapbox.com/help/troubleshooting/private-access-token-android-and-ios/#ios) containing your access token.

## Building from source

Run `make deps`. (If you have changed versions of Xcode, it's recommended that the Carthage caches are deleted; you can do this by running `make distclean`.)

Then, open `MapboxMaps.xcworkspace` to view the project in Xcode.

## Adding libraries

A library is a highly cohesive group of software components that has **one** responsibility. 

For example, annotations should only handle the lifecycle of adding, updating, and removing annotations on a map. It is possible to establish a dependency on other libraries with the exception of `MapboxMapsFoundation` library — this library should not depend on any other libraries at any given time, with the exception of the `MapboxCoreMaps` library.

### Creating a new framework target

To add a **new** framework as a target within this project, complete the following steps:

1. Open `MapboxMaps.xcworkspace` workspace. 
<br/>

2. In the workspace select the `MapboxMaps` project then under the list of targets, select the plus button (`+`) to add a new target. In the template view search for `Framework`, select it, and then click on _Next_. On the next dialogue window:

    * Set the `Product Name` as the name of the framework, prefixed with `MapboxMaps` (i.e., `MapboxMapsGestures`, `MapboxMapsOrnaments`, etc).
    * Make sure Swift is selected as the language.
    * Make sure `MapboxMaps` is selected as project.
    * Check the `Include Unit Tests` box.
    * Make sure `Embed in Application` is set to `None`.
    * Finally, select _Finish_.

    Additional target configurations are specified with the `Mapbox.xcconfig` and `base.xcconfig` files. Currently these apply to all targets.

    Please check your build settings for the new target to delete any settings that override the defaults specified in the above `xcconfig` files. For example, you may find that the deployment target is incorrect.
    <br/>

3. Add your files. **Important note:** For every new file you add to your target, make sure its target membership is to the framework you've added. In addition, make the file a member of the the `MapboxMaps` target as well.
<br/>

4. (Optional) If the framework will have a dependency on `MapboxCoreMaps` or `MapboxCommon`, perform the following extra steps:

    1. Select the `MapboxMaps` project from the Navigator panel.
    2. Select the framework you just added under _Targets_.
    3. Go to the _General_ tab. Under the _Frameworks and Libraries_ section, and add the `MapboxCoreMaps`/`MapboxCommon` framework. For the embedding option, choose `Do not embed`.
    <br/>

5. For the new framework's associated unit test target, go to the Project Settings for `MapboxMaps`. Under "Configurations", make sure your test target specifies the `unitTests` configuration file for debug and release mode. This will ensure test targets are linked properly to other internal frameworks. 
<br/>

   Note: Framework tests run on the simulator - **they no longer run on device**. Instead, please add your Swift test files to the `MapboxMapsTests` and `MapboxMapsTestsWithHost` targets. These two test targets link against the singular `MapboxMaps` framework; `MapboxMapsTest` can be used for simulator testing, where `MapboxMapsTestsWithHost` will be used for device testing.

### How to test a new framework on Circle CI


1. Add a new step to the `build-all-targets` job:

    Example:

    ```yaml
    build-all-targets:
        <<: *default-job
        steps:
            - checkout
            - run: make deps
            ...
            - build-scheme:
                scheme: MapboxMapsNewFramework
    ```

2. Similarly, add a test step to the `maps-unit-tests` job:

    Example:

    ```yaml
    # Run the tests in the MapboxTests scheme
    maps-unit-tests:
        <<: *default-job    
        steps:
            - checkout
            - run: make deps
            ...
            - test-scheme:
                scheme: MapboxMapsNewFramework
    ```

**Pro tip**: CircleCI's [YAML](https://en.wikipedia.org/wiki/YAML) format can be picky. You can run `make validate` to 
ensure you've formatted the changes to the config file correctly. This make target will install the [CircleCI command 
line interface](https://circleci.com/docs/2.0/local-cli/) to validate `.circleci/config.yml`, and run `circleci config validate`

From here, you can add new files to your library and commit these changes to GitHub.

# Testing

## Unit Testing on devices

To run device tests there are few options:

1. Run via Xcode: test (Cmd-U) the `MapboxTestsWithHost` scheme.

2. Trigger via CI by adding `[run device tests]` to a git commit message. These tests also run "nightly".

3. Trigger tests on AWS Device Farm from the command line by running `make test-with-device-farm SCHEME=MapboxMapsTestsWithHost APP_NAME=MapboxTestHost`. This requires certain environment variables to be set; please see the makefile for these.

4. Trigger tests on a local device (connected by USB) using the same setup as Device Farm testing by running:
`make local-test-with-device-farm-ipa SCHEME=MapboxTestsWithHost CONFIGURATION=Release ENABLE_CODE_SIGNING=1`

## Integration Tests

Integration tests typically test the integration between components. As such most will require a `MapView`. These can be run locally and on AWS Device Farm.

Integration tests should be added to the `MapboxMapsTests` and `MapboxMapsTestsWithHosts` targets. Since these tests require a map view, they also need a `UIWindow` and Metal rendering to work. For both testing scenarios, if there's no valid Metal device the test will be skipped (i.e. not failure/success).

### What happens if I run from `MapboxMapsTestsWithHost` ?

There **is** a host application, so `MapViewIntegrationTestCase` fetches the existing window and view controller before adding the MapView to it.

- These tests can be run on devices.
- Tests will be skipped on simulators < iOS 13 because there's no valid Metal device. (iOS 13+ has a simulated Metal device.)

### What happens if I run from `MapboxMaps`

There is **no host application**, so `MapViewIntegrationTestCase` creates its own `UIWindow` and root view controller, before adding the MapView to it.

- These tests cannot be run on devices.
- Tests will be skipped on simulators < iOS 13 because there's no valid Metal device.
- Tests will be skipped entirely on CircleCI because of the VM (no Metal). **So for CI purposes, integration tests should be run on AWS Device Farm via `MapboxMapsTestsWithHost`**

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
* Check out this [doc](https://github.com/mapbox/mapbox-maps-ios/blob/main/Examples/README.md) to get more information about adding examples to our project
