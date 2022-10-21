# Debuggable Environment

## Prerequisites

Several utilities are required to use this script. You can install them with:

```
$ brew install xcodegen cmake ccache glfw pkgconfig jq
```

## Setup

1. Clone this repository
2. Run `$ ./generate-debuggable-environment [-h] [--commit COMMIT] [--gl-native-commit GL_NATIVE_COMMIT] [--turf-commit TURF_COMMIT] [--mme-commit MME_COMMIT] [--stable]`
3. When the script completes, `MapboxMaps.xcodeproj` will open.
4. Build and run the `Examples` scheme to start debugging:

   ![Screen Shot 2020-12-04 at 4 35 47 PM](https://user-images.githubusercontent.com/6844889/101218658-7bab3200-3651-11eb-9933-c1f8420695dd.png)
5. Press Cmd+U to run unit tests along with Examples tests. Choose `MapboxMaps` scheme to run only unit tests.
