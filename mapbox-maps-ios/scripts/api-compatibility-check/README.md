# API Compatibility Check

## What is it?

API compatibility checks help to ensure that we do not accidentally break the public API. The set of scripts runs Apple's `swift-api-digester` tool to dump the public API into a reusable JSON file for comparison with other versions.

## How to run

The `breaking-api-check.py` Python script has two mods – `dump` and `check-api`.
To compare two versions you have to dump each of them first and then run comparison check.
It is recommended to dump SDKs with the same Xcode version as there are might be differences in the output format.
Another recommendation is to use Xcode 13.1 or newer as there are some fixes in the `swift-api-digester` tool.

### Dumping SDK

SDK dumping subcommand is used to dump the public API of the SDK into a JSON file.
It supports a few input formats:

1. Zip archive of XCFrameworks (can be nested in one level folder). Archive should contain all non-Apple dependencies in XCFramework format as well.
2. Dumping directly from XCFramework. In this case script would expect dependencies to be in the same folder as the main XCFramework.
3. Dumping from DerivedData Products folder. You have to provide path to the folder like `…/DerivedData/<app-name>-<xcode-id>/Build/Products/Release-iphoneos/` and the script will find all swift modules in it. That mode can be easily integrated into existing building jobs. Unfortunately, in this case script cannot detect triplet target automatically and you have to provide it manually with `--triplet-target`.

Most of the time you also have to specify `--module` name to help script to find appropriate module.
If no `-o`/`--output-path` is provided, script will dump the JSON file into the same folder as the input file with `<module-name>.API.json` name.

### Comparing SDK dumps

When you have two dumps from different version built with the same Xcode version, you can run comparison check. Just pass two JSON files to the script and it will compare them and print the result: `breaking-api-check.py check-api baseline.API.json latest.API.json`.
Note that first file is assumed to be the baseline and second is the latest version.
It is possible to provide whitelist file to ignore some changes. The content of file should include exactly the same failure message you see in the report. The `--breakage-allowlist-path` argument is responsible for that.
To configure report output you can use `--report-path` argument. By default, the report will be saved in local `api-check-report.txt` file and printed to the console only in case of any error.
If you have installed `gh` command line tool, you can also use `--comment-pr` argument to post the report as a comment to the PR. That report would be ignored as long as no breaking changes are detected and will override the previous comment if it exists.

## What is `swift-api-digester`?

Swift API digester is an official tool to dump public API to JSON representation based on AST and compare dumps if needed.

### Limitations

`swift-api-digester` has existed in the open source Swift toolchain for quite a while, but it was not included in Xcode until Xcode 13. That's why you have to use Xcode 13 or newer to run breakage checks.
Another limitation is that you must use `swift-api-digester` from the same toolchain you used to build your SDK. You cannot run Xcode 13 digester over the SDK built with Xcode 12.5.1.

### Where to find `swift-api-digester`

To get access to the `swift-api-digester` you have to make a path manually. The handy shortcut can be:

```bash
API_DIGESTER_PATH="xcrun -f swift-api-digester"
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
