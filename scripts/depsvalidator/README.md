# DepsValidator

DepsValidator is a command line utility that can ensure that a library is using
a consistent set of dependency versions across multiple Apple-ecosystem package
managers.

It can validate dependencies specified according to Semantic Versioning with:

- Swift Package Manager
- CocoaPods
- Carthage
- JSON files containing an object with dependency names as keys and the
  corresponding pinned versions as values.

## Usage

To use DepsValidator, you need to write a config file that specifies the paths
to your dependency managers' manifests and lists the dependencencies. By
default, the `depsvalidator` command will look for the config file at
`.depsvalidator.yml` in the current directory. You may specify a different file
using the `--config-file` option.

### Config File Structure

The config file has the following structure:

```yaml
---
manifests:
  - type: [Package.swift, Package.resolved, Podspec, Cartfile, Cartfile.resolved, JSON]
    path: {path to manifest}
    omit_for:
      - {dependency name}
dependencies:
  - name: {dependency name}
    variations:
      [SPM, CocoaPods, Carthage, JSON]: {name variation}
```

- `manifests`: An array of manifest declarations.
  - `type`: The type of manifest. Must be one of the values listed above.
  - `path` [optional]: The path to the manifest, relative to the path of the
    config file. By default, depsvalidator will look in the same directory as
    the config file. The default path for JSON manifests is `versions.json`.
  - `omit_for` [optional]: An array of dependency names which should not be
    expected in the manifest. The name must match the name of one of the
    dependencies listed in this config file.
- `dependencies`: An array of dependency declarations.
  - `name`: The name of the dependency.
  - `variations`: a dictionary that can be used to override the name of the
    dependency for specific package managers. Keys are one of the values shown
    above. Values are the correct name for that package manager.

It is permissible to have more than one manifest of a given type. For
example, if your repository hosts a Swift package and an Xcode workspace that
uses Swift packages, you'll likely have two Package.resolved files (one in the
repo root, and one at
`YourWorkspace.xcworkspace/xcshareddata/swiftpm/Package.resolved`).

### Command Line Invocation

You can build and test DepsValidator using the standard Swift Package Manager
command line techniques, including `swift build` and `swift test`. You can also
run it directly using `swift run depsvalidator {subcommand} {arguments}`.

#### Validate Subcommand

`depsvalidator [validate] [--config-file {config_file_path}]`

Runs validation. Exits with 0 on success and non-0 otherwise. This command
validates:

1. Dependency version requirements are specified equivalently.
2. Pinned dependency versions are specified equivalently.
3. The dependency version requirement is satisfied by the corresponding pinned
   dependency version.

### CI Usage

DepsValidator can be used in CI workflows to help maintain a consistent set of
versions in a repo's main branch. Configure your CI workflow for pull requests
to run the validate subcommand. The job should fail if depsvalidator exits with
a non-0 exit code.

## Developing

DepsValidator itself is built using Swift and Swift Package Manager. It can be
developed by opening its Package.swift in Xcode. To run the tests, you will need
to set the `DEPSVALIDATOR_POD_EXECUTABLE_PATH` environment variable on your
scheme so that DepsValidator can locate your CocoaPods `pod` executable. To run
from Xcode, specify `--config-file={path_to_config_file}` in the scheme's launch
arguments. Optionally, specify either the `validate` or `dump` subcommand as
well.

DepsValidator uses [SwiftLint](https://github.com/realm/SwiftLint). Install and
run it from the command line.

### Ideas

- Replace JSON file support with generic custom manifest support. Allow users to
  specify a command-line invocation with the dependency name as a wildcard. The
  command-line invocation should send the version or version requirement to
  standard out.
- Add a `dump` subcommand that produces a human-readable dump of the
  currently-specified dependency requirements and dependency versions. Only
  dependencies listed in the config file will be included in the output. Add
  `--by-manifest` and `--by-dependency` options to allow the user to configure
  how the output should be organized.
