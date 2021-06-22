# Debuggable Environment

## Setup

1. Clone this repository
2. Run `$ ./generate-debuggable-environment.sh <mapbox-maps-ios-treeish> <gl-native-internal-treeish> <sdk>`
3. When the script completes, `Umbrella.xcworkspace` will open.
4. Set a custom `DerivedData` path for `Umbrella.xcworkspace` by opening `Workspace Settings`:

   ![Screen Shot 2020-12-04 at 4 35 28 PM]
    (https://user-images.githubusercontent.com/6844889/101218237-bb254e80-3650-11eb-80e3-f266dd28962a.png)

   Set the Derived Data path to `Workspace-relative Location` with name
   `DerivedData`:

   ![Screen Shot 2020-12-04 at 4 34 32 PM]
    (https://user-images.githubusercontent.com/6844889/101218467-1d7e4f00-3651-11eb-9ae9-38ce705c91b6.png)

5. Build and run the `DebugApp` scheme to start debugging:

   ![Screen Shot 2020-12-04 at 4 35 47 PM]
    (https://user-images.githubusercontent.com/6844889/101218658-7bab3200-3651-11eb-9933-c1f8420695dd.png)
