# mapbox-maps-ios-internal

## How to use this repo as a debuggable environment?

In its current state, it's possible to create the end-to-end debuggable environment, but there are a couple manual steps. Here's how to use it:
1. Clone this repository
2. Run `git submodule update --init --recursive` manually (takes about 10 minutes)
3. Checkout your required branches of `mapbox-gl-native-internal` and `mapbox-maps-ios` and update submodules if needed.
4. Run `sh generate-debuggable-environment.sh` with your required branches. 
5. Once the script above completes -- the `Umbrella.xcworkspace` will open.
6. Only thing remaining is to ensure that you set a well-known path to `DerivedData` (the directory where `MapboxCoreMaps.framework` gets built into). 

   To do this, open the `Workspace Settings` here:

   ![Screen Shot 2020-12-04 at 4 35 28 PM](https://user-images.githubusercontent.com/6844889/101218237-bb254e80-3650-11eb-80e3-f266dd28962a.png)

   Make sure to set the Derived Data path to `Workspace-relative Location` like so (while making sure the name of the directory stays as "DerivedData":
   
   ![Screen Shot 2020-12-04 at 4 34 32 PM](https://user-images.githubusercontent.com/6844889/101218467-1d7e4f00-3651-11eb-9ae9-38ce705c91b6.png)

7. Run the `DebugApp` target for a simulator and everything should work (tm):
   
   ![Screen Shot 2020-12-04 at 4 35 47 PM](https://user-images.githubusercontent.com/6844889/101218658-7bab3200-3651-11eb-9933-c1f8420695dd.png)

## How to use the fat framework script

* Download the zip bundle of the maps SDK from SDK Registry
* Navigate to the root of thi directory. This is where the script is located.
* Then run `./create-maps-frameworks.swift {Path_To_Zip_Bundle}`
* This script does not care if the bundle is the static or dynamic bundle
    * If you pass in a dynamic bundle, the result is a set of dynamic fat frameworks
    * If you pass in a static bundle, the result is a set of static fat frameworks
* The frameworks will be located in a directory called MapboxMapsFrameworks

### Known issues:
- Currently this will work only for simulators. To make it work for devices you have to change the Cmake invocation in `generate-debuggable-environment.sh` to build for `iphoneos ` instead of `iphonesimulator` -- you may also have to change the symlinks.
