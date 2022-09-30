#!/usr/bin/swift sh
import Foundation
import XcodeProj  // @tuist ~> 8.8.0
import PathKit

guard CommandLine.arguments.count == 2 else {
    let arg0 = Path(CommandLine.arguments[0]).lastComponent
    fputs("usage: \(arg0) <project>\n", stderr)
    exit(1)
}

extension String {
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
}

class GLNativeProject {
    let path: Path
    let xcproject: XcodeProj

    init(path: Path) throws {
        self.path = path
        self.xcproject = try XcodeProj(path: path)
    }

    func write(override: Bool = true) throws {
        try self.xcproject.write(path: path, override: override)
    }

    func fixProjectSettings() {
        guard let buildConfigurationList = xcproject.pbxproj.rootObject?.buildConfigurationList else {
            return
        }

        for config in buildConfigurationList.buildConfigurations {
            let isDebug = config.name.lowercased() == "debug"

            config.buildSettings["SYMROOT"] = nil
            config.buildSettings["INSTALL_PATH"] = nil
            config.buildSettings["SKIP_INSTALL"] = "YES"
            config.buildSettings["ONLY_ACTIVE_ARCH"] = isDebug ? "YES" : "NO"
            config.buildSettings["LLVM_LTO"] = isDebug ? nil : "NO"
        }
    }

    func fixTargetSettings() {
        xcproject.pbxproj.nativeTargets.forEach { target in
            target.buildConfigurationList?.buildConfigurations.forEach { buildConfiguration in
                let buildSettingsToNil = [
                    "SYMROOT",
                    "INSTALL_PATH",
                    "SKIP_INSTALL",
                    "CONFIGURATION_BUILD_DIR",
                    "LD_RUNPATH_SEARCH_PATHS",
                    "SECTORDER_FLAGS",
                    "ONLY_ACTIVE_ARCH",
                    "LLVM_LTO",
                    "CLANG_DEBUG_INFORMATION_LEVEL",
                    "EXECUTABLE_PREFIX",
                    "FRAMEWORK_VERSION"
                ]
                for buildSetting in buildSettingsToNil {
                    buildConfiguration.buildSettings[buildSetting] = nil
                }

                if let linkerFlags = buildConfiguration.buildSettings["OTHER_LDFLAGS"] as? [String] {
                    let pathPrefix = path.parent().absolute().string

                    let newLinkerOptions = linkerFlags.compactMap { (linkerFlag: String) in
                        guard linkerFlag.starts(with: pathPrefix) else { return linkerFlag }
                        let libraryFullName = Path(linkerFlag).lastComponentWithoutExtension

                        return "-l" + libraryFullName.deletingPrefix("lib")
                    }

                    buildConfiguration.buildSettings["OTHER_LDFLAGS"] = newLinkerOptions
                }

                // There is the same value under the `xcproject.pbxproj.rootProject()!.projectDirPath`.
                // We have to investigate this approach. The challenge here is that `projectDirPath` an empty string in most projects
                let projectRoot = path.parent().parent().parent().absolute().string + "/"
                buildConfiguration.buildSettings = buildConfiguration.buildSettings.mapValues { setting in
                    switch setting {
                        case let setting as [String]:
                            return setting.map({ $0.deletingPrefix(projectRoot) })
                        case let setting as String:
                            return setting.deletingPrefix(projectRoot)
                        default:
                            break
                    }
                    return setting
                }
            }
        }
    }
}

let projectPath = Path(CommandLine.arguments[1])

guard projectPath.isDirectory else {
    print("Xcodeproject doesn't exist at path: \(projectPath.absolute().string)")
    exit(EXIT_FAILURE)
}

let project = try GLNativeProject(path: projectPath)
print("Patching project at:", projectPath.absolute().string)
project.fixProjectSettings()
project.fixTargetSettings()
try project.write()

print("Done at", Date())
