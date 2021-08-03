---
name: Update dependencies template
about: This is the template for updating dependencies in our repo
title: 'Update Dependencies For Maps SDK (see description for versions)'
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
- [ ] Create a new branch `git checkout -b update_dependencies_for_<Core|Common|Events|Turf>`
- [ ] Open `scripts/release/packager/versions.json` and replace dependencies with new version pointers
- [ ] Open `MapboxMaps.podspec` and replace dependencies with new version pointers
- [ ] Using Xcode, open `Package.swift` and replace dependencies with new version pointers
- [ ] Go to File > Packages > Update to Latest Package Versions
    - If there are issues with downloading dependencies, consider resetting your package caches or deleting derived data
- [ ] Build the project
    - [ ] Fix any compile/build issues and commit to this branch
    - [ ] Document any necessary changes in the `CHANGELOG.md`
- [ ] It is important that you commit the changes to the `project` file, and the `Package.resolved`
- [ ] Open `Apps/Apps.xcworkspace` and ensure that all the projects build and run successfully
- [ ] Create a PR and have the team review changes and the `CHANGELOG.md`