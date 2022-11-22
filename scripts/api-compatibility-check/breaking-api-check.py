#!/usr/bin/env python3
import os
import argparse
import subprocess
import plistlib
import shutil
import sys
import tempfile
import hashlib

def dump_sdk(sdk_path:str, output_path:str, abi:bool):
    tempDir = tempfile.mkdtemp(prefix="API-check-")
    print(tempDir)

    def dittoSDK(sdk_path, destination):
        if os.path.splitext(sdk_path)[1] == ".zip":
            shutil.unpack_archive(sdk_path, destination)
            return os.path.join(destination, "artifacts")
        else:
            raise Exception("SDK path must be a zip archive")

    current_artifacts_dir = dittoSDK(sdk_path, tempDir)
    current_xcframework = XCFramework(os.path.join(current_artifacts_dir, "MapboxMaps.xcframework"))

    digester = APIDigester()
    digester.dump_sdk(current_xcframework, current_artifacts_dir, output_path, abi)

def check_api_breaking_changes(baseline_dump_path:str, latest_dump_path:str, breakage_allow_list_path:str, report_path:str):
    tool = APIDigester()

    tool.compare(baseline_dump_path, latest_dump_path, report_path, breakage_allow_list_path)


    sha_hash = hashlib.sha1()
    with open(report_path, "rb") as f:
        # Read and update hash string value in blocks of 4K
        for byte_block in iter(lambda: f.read(4096),b""):
            sha_hash.update(byte_block)
        report_hashsum = sha_hash.hexdigest()

    if report_hashsum != __empty_report_hashsum():
        print(f"""
======================================
ERROR: API breakage detected in {os.path.basename(latest_dump_path)}
======================================
{open(report_path, "r").read()}
        """, file=sys.stderr)
        exit(1)

def main():
    parser = argparse.ArgumentParser(
            description="Build and check the API compatibility of the Mapbox Maps SDK for iOS.")

    subparsers = parser.add_subparsers(dest='command')

    dumpSDKParser = subparsers.add_parser("dump", help="Generate JSON API report.")
    dumpSDKParser.add_argument("sdk_path", metavar="sdk-path", type=os.path.abspath, help="Path to the Maps SDK release zip archive.")
    dumpSDKParser.add_argument("--abi", default=False, action=argparse.BooleanOptionalAction, help="Generate ABI report.")
    dumpSDKParser.add_argument("-o", "--output-path", type=os.path.abspath, default="MapboxMaps.json", help="Path to the output JSON API report.")

    checkAPIParser = subparsers.add_parser("check-api", help="Check for API breakage.")
    checkAPIParser.add_argument("base_dump", metavar="base-dump-path", type=os.path.abspath, help="Path to the baseline (old) SDK API JSON dump.")
    checkAPIParser.add_argument("latest_dump", metavar="latest-dump-path", type=os.path.abspath, help="Path to the latest (new) SDK API JSON dump.")
    checkAPIParser.add_argument("--breakage-allowlist-path", type=os.path.abspath, help="Path to the file containing the list of allowed API breakages.")
    checkAPIParser.add_argument("--report-path", default="api-check-report.txt", type=os.path.abspath, help="Path to the API check report.")

    args = parser.parse_args()
    print(args)

    if args.command == "dump":
        dump_sdk(args.sdk_path, args.output_path, args.abi)
    elif args.command == "check-api":
        check_api_breaking_changes(args.base_dump, args.latest_dump, args.breakage_allowlist_path, args.report_path)
    exit(0)

    args.sdk_path = "/Users/odnairy/Downloads/MapboxMaps.zip"
    args.baseline_sdk_path = "/Users/odnairy/Downloads/MapboxMaps-baseline.zip"

    # Make temporary directories to extract the SDKs into.
    tempDir = tempfile.mkdtemp(prefix="MapboxMaps-API-check-")
    print(tempDir)

    def dittoSDK(sdk_path, destination):
        if os.path.splitext(sdk_path)[1] == ".zip":
            shutil.unpack_archive(sdk_path, destination)
            return os.path.join(destination, "artifacts")
        else:
            raise Exception("SDK path must be a zip archive")

    current_artifacts_dir = dittoSDK(args.sdk_path, os.path.join(tempDir, "current"))
    baseline_artifacts_dir = dittoSDK(args.baseline_sdk_path, os.path.join(tempDir, "baseline"))


    maps_current_xcframework = XCFramework(os.path.join(current_artifacts_dir, "MapboxMaps.xcframework"))
    maps_baseline_xcframework = XCFramework(os.path.join(baseline_artifacts_dir, "MapboxMaps.xcframework"))

    tool = APIDigester()
    current_dump = os.path.join(current_artifacts_dir, "current.json")
    baseline_dump = os.path.join(baseline_artifacts_dir, "baseline.json")

    tool.dump_sdk(maps_current_xcframework, current_artifacts_dir, current_dump)
    tool.dump_sdk(maps_baseline_xcframework, baseline_artifacts_dir, baseline_dump)

    report_path = os.path.join(tempDir, "report.txt")
    tool.compare(baseline_dump, current_dump, report_path)


    sha_hash = hashlib.sha1()
    with open(report_path, "rb") as f:
        # Read and update hash string value in blocks of 4K
        for byte_block in iter(lambda: f.read(4096),b""):
            sha_hash.update(byte_block)
        report_hashsum = sha_hash.hexdigest()

    if report_hashsum != __empty_report_hashsum():
        print(f"""
======================================
ERROR: API breakage detected in {maps_current_xcframework.name}
======================================
{open(report_path, "r").read()}
        """, file=sys.stderr)
        exit(1)

def __empty_report_hashsum():
    # Represents a sha1 hashsum of an empty report (including section names).
    return "afd2a1b542b33273920d65821deddc653063c700"

class APIDigester:

    def compare(self, baseline_path, current_path, output_path, breakage_allow_list_path:str = None):
        arguments = ["xcrun", "--sdk", "iphoneos", "swift-api-digester",
                    "-diagnose-sdk",
                    "-o", output_path,
                    "-input-paths", baseline_path,
                    "-input-paths", current_path,
                    "-v"
                    ]

        if breakage_allow_list_path:
            arguments.append("-breakage-allowlist-path")
            arguments.append(breakage_allow_list_path)

        proc = subprocess.run(arguments, capture_output=True, text=True)
        if proc.returncode != 0:
            print(proc.stderr)
            raise Exception("swift-api-digester failed")

    def dump_sdk(self, xcframework: 'XCFramework', dependencies_path, output_path, abi: bool = False):
        module = xcframework.iOSDeviceModule()
        arguments = ["xcrun", "--sdk", "iphoneos", "swift-api-digester",
                    "-dump-sdk",
                    "-o", output_path,
                    "-abort-on-module-fail",
                    "-v",
                    "-avoid-tool-args", "-avoid-location",
                    ]

        if abi:
            arguments.append("-abi")

        def append_dependencies(arguments: list):
            deps = module.list_dependencies()
            deps_names = map(lambda dep: os.path.basename(dep), deps)
            xcDeps = list(map(lambda dep: XCFramework(os.path.join(dependencies_path, dep)), [d for d in os.listdir(dependencies_path) if os.path.isdir(os.path.join(dependencies_path, d)) and d.endswith('.xcframework')]))

            for dependency in deps:
                dependency_name = os.path.basename(dependency)
                for xcDep in xcDeps:
                    if xcDep.name == dependency_name:
                        arguments.append("-iframework")
                        arguments.append(os.path.dirname(xcDep.iOSDeviceModule().path))
                        break

        def append_module(arguments: list):
            module = xcframework.iOSDeviceModule()
            arguments.extend([
                "-module", xcframework.name,
                "-target", module.triplet_target(),
                "-iframework", os.path.dirname(module.path),
                ])

        append_dependencies(arguments)
        append_module(arguments)

        # print("Running command: " + " ".join(arguments))
        proc = subprocess.run(arguments, capture_output=True, text=True)
        if proc.returncode != 0:
            print(proc.stderr)
            raise Exception("swift-api-digester failed")

class SDKModule:
    def __init__(self, root, library: 'XCFramework.Library'):
        self.library = library
        self.path = os.path.join(root, library.libraryIdentifier(), library.path())
        self.__parse_info_plist()

    def __parse_info_plist(self):
        with open(os.path.join(self.path, "Info.plist"), "rb") as f:
            self.plist = plistlib.load(f)

    def minimum_os_version(self):
        return self.plist["MinimumOSVersion"]

    def triplet_target(self):
        # Returns the target triple for the module in format 'arm64-apple-ios11.0'
        return f"{self.library.supported_architectures()[0]}-apple-{self.library.supported_platform()}{self.minimum_os_version()}"

    def executable_path(self):
        return self.plist["CFBundleExecutable"]

    def executable(self) -> os.path:
        return os.path.join(self.path, self.executable_path())

    def __repr__(self):
        return f"SDKModule({self.path, self.plist})"

    def list_all_dependencies(self):
        dynamic_dependencies = subprocess.run(["xcrun", "otool", "-L", self.executable()], capture_output=True, text=True).stdout.strip().split("\n\t")
        return list(map(lambda x: x.split()[0], dynamic_dependencies[1:]))

    def list_dependencies(self):
        def filter_system_dependencies(dependency):
            return not dependency.startswith("/usr/lib") \
                and not dependency.startswith("/System") \
                    and not dependency.endswith(".dylib") \
                        and not dependency.endswith("MapboxMaps.framework/MapboxMaps")

        return list(filter(filter_system_dependencies, self.list_all_dependencies()))

class XCFramework:
    class Library:
        def __init__(self, library, root_path):
            self.library = library
            self.root_path = root_path

        def __repr__(self):
            return f"XCFramework.Library({self.library})"

        def path(self) -> str:
            return self.library["LibraryPath"]

        def libraryIdentifier(self) -> str:
            return self.library["LibraryIdentifier"]

        def supported_platform(self) -> str:
            return self.library["SupportedPlatform"]

        def supported_platform_variant(self) -> str:
            return self.library["SupportedPlatformVariant"]

        def supported_architectures(self) -> list:
            return self.library["SupportedArchitectures"]

        def is_simulator(self):
            return self.supported_platform_variant() == "simulator"

        def is_device(self):
            return not "SupportedPlatformVariant" in self.library

        def is_ios(self):
            return self.supported_platform() == "ios"

        def is_macos(self):
            return self.supported_platform() == "macos"

    def __init__(self, path):
        self.path = os.path.abspath(path)

        if not os.path.isdir(self.path) and self.path.endswith(".xcframework"):
            raise Exception(f"{self.path} is not a valid XCFramework")

        self.name = os.path.basename(self.path).split(".")[0]
        self.libraries = self.__parse_libraries()

    def __parse_libraries(self):
        with open(os.path.join(self.path, "Info.plist")) as f:
            plist = plistlib.loads(f.read().encode("utf-8"))
            return list(map(lambda x: XCFramework.Library(x, self.path), plist["AvailableLibraries"]))

    def iOSDeviceModule(self):
        deviceLibrary = list(filter(lambda x: x.is_ios() and x.is_device(), self.libraries))[0]
        # return SDKModule(os.path.join(self.path, deviceLibrary.libraryIdentifier(), deviceLibrary.path()))
        return SDKModule(self.path, deviceLibrary)

    def __repr__(self):
        return f"XCFramework({self.path})"

if __name__ == "__main__":
    main()