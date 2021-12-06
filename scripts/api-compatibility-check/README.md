# API Compatibility Check

## What is it?

API compatibility checks help to ensure that we do not accidentally break the public API. The set of scripts runs Apple's `swift-api-digester` tool to dump the public API into a reusable JSON file for comparison with other versions.

## How to run

You can find two scripts in this folder. The first, `breaking-api-check.sh`, is designed to run a set of public API checks over the pre-built baseline. The second, `rebuild-baseline.sh`, helps to generate a new baseline based on a git reference. Let's take a closer look at each of them.

### `breaking-api-check.sh`

`breaking-api-check.sh` accepts an optional argument `-p path` which should be a packaged version of MapboxMaps. Without the `-p` argument, the script triggers `scripts/release/packager/package-mapbox-maps.sh` to build XCFramework from scratch. It is useful to specify the path of a pre-built binary to avoid the extra building steps. Breaking API checks running against the `.baseline.zip` JSON API digester dump. To update the baseline, see `rebuild-baseline.sh`.

The script is path-independent so you can call it from any other folder with an absolute or relative path.

### `rebuild-baseline.sh`

`rebuild-baseline.sh` simplifies baseline data updates. Usually, we should not update the baseline within a single major version. However, the digester tool triggers breaking changes for `@_spi` changes as well which is not the desired behavior since we use these to denote experimental APIs which we reserve the right to change outside of a major version bump.

To update the baseline, update the `.baseapi` file to include a new git reference, then call the script. The new git worktree is checked out in a hidden folder for script purposes.

Upon success, you will get an updated version of `.baseline.zip`. This archive represents folder structure with JSON SDK API dump made by swift-api-digester. It is a native structure for `swift-api-digester` so we can easily extend our platform validations to include macosx/watchos or any other Apple platform.

## What is `swift-api-digester`?

Swift API digester is an official tool to dump public API to JSON representation based on AST and compare dumps if needed.

### Limitations

`swift-api-digester` has existed in the open source Swift toolchain for quite a while, but it was not included in Xcode until Xcode 13. That's why you have to use Xcode 13 or newer to run breakage checks.
Another limitation is that you must use `swift-api-digester` from the same toolchain you used to build your SDK. You cannot run Xcode 13 digester over the SDK built with Xcode 12.5.1.

### Where to find `swift-api-digester`

To get access to the `swift-api-digester` you have to make a path manually. The handy shortcut can be:

```bash
API_DIGESTER_PATH="$(xcode-select -p)/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-api-digester"
```

There is no access to `swift-api-digester` through the `$PATH` or even `xcrun`.

### Options

There are a few modes in `swift-api-digester` but we would use only two:

1. First is `--dump-sdk` mode. As it says, you can build the SDK API dump to the JSON file. It's possible to make a dump based on source code or pre-compiled SDK. You must provide SDK path (iphoneos or other) with `-sdk` argument or through `xcrun -sdk iphoneos swift-api-digester …`. 
Pay attention to the `-target` argument which requires clang triplet like `arm64-apple-ios11.0`. To find the compilation options of your framework, open a `YOUR_FRAMEWORK.framework/Modules` folder and find any of `.swiftinterface` files. One of the top lines in this file starts with `swift-module-flags` and contains target compilation triplet (for example, `// swift-module-flags: -target arm64-apple-ios11.0`).
Call example:

    ```bash
    xcrun --sdk iphoneos "$API_DIGESTER_PATH"\
        --dump-sdk \
        --module=MapboxMaps\
        -I "$PRODUCT_ARTIFACTS_DIR"/MapboxMaps.xcframework/ios-arm64/MapboxMaps.framework/\
        -I "$PRODUCT_ARTIFACTS_DIR"/MapboxCommon.xcframework/ios-arm64_armv7/MapboxCommon.framework/\
        -I "$PRODUCT_ARTIFACTS_DIR"/MapboxCoreMaps.xcframework/ios-arm64/MapboxCoreMaps.framework/\
        -I "$PRODUCT_ARTIFACTS_DIR"/MapboxMobileEvents.xcframework/ios-arm64/MapboxMobileEvents.framework/\
        -I "$PRODUCT_ARTIFACTS_DIR"/Turf.xcframework/ios-arm64/Turf.framework/\
        -target arm64-apple-ios11.0\
        --iframework "$PRODUCT_ARTIFACTS_DIR"/MapboxCommon.xcframework/ios-arm64_armv7/ \
        --iframework "$PRODUCT_ARTIFACTS_DIR"/MapboxCoreMaps.xcframework/ios-arm64/ \
        --abort-on-module-fail\
        --avoid-tool-args --avoid-location\
        --output-dir "$SCRIPT_DIR" \
        -v
    ```

2. The second is `--diagnose-sdk`. In that mode, tool would compare two input JSON (or current project against baseline) and print comparison summary. The basic call would look like:

    ```bash
    swift-api-digester --diagnose-sdk -input-paths old-api.json -input-paths new-api.json
    ```

    It is also possible to run diagnosis against the baseline. First, create folder `API` in the baseline root, then add iOS SDK dump and rename it to `iphoneos.json`. Afterward, pass `--baseline-dir "$BASELINE_DIR"` to digester without the first `-input-paths` argument.
    You also can replace the last `-input-paths` with Clang Module search options so the digester would dump the current SDK in place for you. It is how `breaking-api-check.sh` script works.

## Want to learn more?

You can find more information about `swift-api-digister` tool in Apple's official Swift repository. The most useful are the following links:

- Swift API Digester [unit tests](https://github.com/apple/swift/tree/swift-5.5.1-RELEASE/test/api-digester)
- Swift API Digester [source code](https://github.com/apple/swift/blob/swift-5.5.1-RELEASE/tools/driver/swift_api_digester_main.cpp)
- Python wrapper to simplify arguments passing – [swift-api-checker.py](https://github.com/apple/swift/blob/swift-5.5.1-RELEASE/utils/api_checker/swift-api-checker.py)
- Swift NIO – [No API breakage script](https://github.com/apple/swift-nio/blob/2.35.0/scripts/check_no_api_breakages.sh)