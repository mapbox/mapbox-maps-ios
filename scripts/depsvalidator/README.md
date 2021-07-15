# DepsValidator

DepsValidator is a command line utility that can ensure that a library is using
a consistent set of dependency versions across multiple Apple-ecosystem package
managers.

It can validate dependencies specified according to Semantic Versioning with:

- Swift Package Manager
- CocoaPods
- Carthage
- User-defined manifest types

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
  - type: [Package.swift, Package.resolved, Podspec, Cartfile, Cartfile.resolved, or the name of a custom manifest definition]
    path: {path to manifest}
    omit_for:
      - {dependency name}
dependencies:
  - name: {dependency name}
    variations:
      [Package.swift, Package.resolved, Podspec, Cartfile, Cartfile.resolved, or the name of a custom manifest definition]: {name variation}
manifest_definitions:
  - name: {custom manifest definition name}
    type: [SemanticVersion, SemanticVersionRequirement]
    default_path: {absolute or config-relative path}
    command: {a bash command that emits the version or version requirement}
```

- `manifests`: An array of manifest declarations. It is permissible to have more
  than one manifest of a given type. For example, if your repository hosts a
  Swift package and an Xcode workspace that uses Swift packages, you'll likely
  have two Package.resolved files (one in the repo root, and one at
  `YourWorkspace.xcworkspace/xcshareddata/swiftpm/Package.resolved`).
  - `type`: The type of manifest. Must be one of the values listed above.
  - `path` [optional]: The path to the manifest, relative to the path of the
    config file. By default, depsvalidator will look in the same directory as
    the config file. The default path for JSON manifests is `versions.json`.
  - `omit_for` [optional]: An array of dependency names which should not be
    expected in the manifest. The name must match the name of one of the
    dependencies listed in this config file.
- `dependencies`: An array of dependency declarations.
  - `name`: The name of the dependency.
  - `variations` [optional]: a dictionary that can be used to override the name
    of the dependency for specific manifest types. Keys are one of the values
    shown above. Values are the correct dependency name for that manifest type.
- `manifest_definitions` [optional]: An array of custom manifest definitions.
  Use this if your project stores dependency versions or version requirements in
  a format other than one for which there is built-in support.
  - `name`: a name for the custom manifest definition. Names must be unique. You
    may override the implementations for the built-in definitions by creating a
    custom one with the same name.
  - `type`: whether the output of the `command` should be interpreted as a
    version or a version requirement. If `SemanticVersion` is specified, the
    command output should be a string representation of a semantic version. If
    `SemanticVersionRequirement` is specified, the output should be a JSON
    object with one of the following structures:

    ```
    // Any version
    {"type": "any"}

    // Exactly one version
    {"type": "exactly", "value": "<<SemanticVersion>>"}

    // A half-open range of versions
    {"type": "range", "from": "<<SemanticVersion>>", "to": "<<SemanticVersion>>"}
    ```

  - `default_path`: the path to look for the manifest if a manifest object of
    this type does not specify a path.
  - `command`: a shell command to run with `/bin/bash -c` which should send the
    semantic version or version requirement to standard output. The environment
    variables `$DEPSVALIDATOR_MANIFEST_PATH` and
    `$DEPSVALIDATOR_DEPENDENCY_NAME` will be populated in the environment for
    use in the command. Note that dependency names may be overridden on a
    per-manifest-type basis using `dependencies.variations` (described above).

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
to set the `PATH` environment variable on your scheme so that DepsValidator can
locate your CocoaPods `pod` executable and any others referenced in custom
manifest definitions. To run from Xcode, specify
`--config-file={path_to_config_file}` in the scheme's launch arguments.
Optionally, specify the `validate` subcommand as well.

DepsValidator uses [SwiftLint](https://github.com/realm/SwiftLint). Install and
run it from the command line.

### Ideas

- Add a `dump` subcommand that produces a human-readable dump of the
  currently-specified dependency requirements and dependency versions. Only
  dependencies listed in the config file will be included in the output. Add
  `--by-manifest` and `--by-dependency` options to allow the user to configure
  how the output should be organized.
