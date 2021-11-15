---
name: Update dependencies template
about: This is the template for updating dependencies
title: 'Update Dependencies'
labels: 'release'
assignees: ''

---

## Document current and new versions

* Only record the version that are changing, delete any versions that are staying the same

MapboxCoreMaps: <current version> -> <new version>
MapboxCommon: <current version> -> <new version>
MapboxEvents: <current version> -> <new version>
Turf: <current version> -> <new version>

## Steps to update

- [ ] Create a new branch from `main`
- [ ] Open `scripts/release/packager/versions.json` and replace dependencies with new version pointers
- [ ] Open `MapboxMaps.podspec` and replace dependencies with new version pointers
- [ ] Using Xcode, open `Package.swift` and replace dependencies with new version pointers
- [ ] Go to File > Packages > Update to Latest Package Versions
    - If there are issues with downloading dependencies, consider resetting your package caches or deleting derived data
- [ ] Build the project, fixing any issues
- [ ] Open `Apps/Apps.xcworkspace` and ensure that all the projects build and run successfully
- [ ] Add a new `CHANGELOG.md` entry. This can be succinct.
- [ ] Commit all changes, including `Package.resolved` files
- [ ] Use the PR description to capture any public release notes from GL Native and Common.
