# Debuggable Environment

## Prerequisites

Several utilities are required to use this script. You can install them with:

```
$ brew install xcodegen cmake ccache glfw pkgconfig
```

## Setup

1. Clone this repository
2. Run `$ ./generate-debuggable-environment.sh <mapbox-maps-ios-commit> <gl-native-internal-commit> <turf-commit> <mme-commit>`
3. When the script completes, `Umbrella.xcworkspace` will open.
4. Build and run the `DebugApp` or `Examples` scheme to start debugging:

   ![Screen Shot 2020-12-04 at 4 35 47 PM](https://user-images.githubusercontent.com/6844889/101218658-7bab3200-3651-11eb-9933-c1f8420695dd.png)
