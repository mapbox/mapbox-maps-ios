# mapbox-maps-ios-internal

## How to use this repo as a debuggable environment?

In its current state, it's possible to create the end-to-end debuggable environment, but there are a couple manual steps. Here's how to use it:
1. Clone this repository
2. Run `git submodule update --init --recursive` manually (takes about 10 minutes)
3. Run `sh generate-debuggable-environment.sh` with your required branches. 

**Example**

```bash
# Usage: ./generate-debuggable-environment.sh <mapbox-gl-native-internal branch> <mapbox-maps-ios branch>
./generate-debuggable-environment.sh internal main 
```

This command ☝️ will create a debuggable environment where `mapbox-maps-ios` will be checked out at the latest `main` and `mapbox-gl-native-internal` will be checked out at the latest `internal`. You may choose to provide Git SHAs as well.

4. Once the script above completes -- the `Umbrella.xcworkspace` will open.
5. Only thing remaining is to ensure that you set a well-known path to `DerivedData` (the directory where `MapboxCoreMaps.framework` gets built into). 

To do this, open the `Workspace Settings` here:

![Screen Shot 2020-12-04 at 4 35 28 PM](https://user-images.githubusercontent.com/6844889/101218237-bb254e80-3650-11eb-80e3-f266dd28962a.png)

Make sure to set the Derived Data path to `Workspace-relative Location` like so (while making sure the name of the directory stays as "DerivedData":
![Screen Shot 2020-12-04 at 4 34 32 PM](https://user-images.githubusercontent.com/6844889/101218467-1d7e4f00-3651-11eb-9ae9-38ce705c91b6.png)

6. Run the `DebugApp` target for a simulator and everything should work (tm):
![Screen Shot 2020-12-04 at 4 35 47 PM](https://user-images.githubusercontent.com/6844889/101218658-7bab3200-3651-11eb-9933-c1f8420695dd.png)



### Known issues:
- Currently this will work only for simulators. To make it work for devices you have to change the Cmake invocation in `generate-debuggable-environment.sh` to build for `iphoneos ` instead of `iphonesimulator`
