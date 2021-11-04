---
name: Release Template
about: Checklist for releasing mapbox-maps-ios
title: Release Maps SDK <version>
labels: release
assignees: ''

---

# Release Maps SDK <version>

- Releaser:
    - The releaser kicks off each step, tests the state of the SDK prior to and after the release, and updates the documentation. They should request their release and buddies the afternoon prior to the release.
- Release buddy:
    - The release buddy is on-hand to review PRs generated through the release process and to assist in troubleshooting the release.
- Docs buddy:
    - The docs buddy reviews the documentation PR and assists with troubleshooting docs issues.
- Release commencement time:
- Semantic Version (referred to hereafter as `VERSION`) e.g `v10.0.0-rc.1`:

## Before You Begin

- [ ] Verify that the [MapboxCommon](https://github.com/mapbox/mapbox-sdk-common/releases) and [MapboxCoreMaps](https://github.com/mapbox/mapbox-core-maps-ios/releases) versions that you will use have been released and are available to download via CocoaPods and SPM.
- [ ] Ensure you have `jq` installed: `$ brew install jq`

### Pull requests:

- [ ] mapbox-maps-ios version & changlog updates on main ->
- [ ] mapbox-maps-ios release branch updates ->
- [ ] api-downloads ->
- [ ] mapbox-maps-ios staging docs ->
- [ ] mapbox-maps-ios production docs ->
- [ ] ios-sdk ->
- [ ] studio-preview-ios ->

## 📦 Release MapboxMaps

### Create the Release Branch

- [ ] If the release branch does not exist yet, create it from the latest commit on main. Name it `release/v{MAJOR}.{MINOR}` where `MAJOR` and `MINOR` are the major and minor components of the semantic version.
- [ ] Push this branch without adding any new commits. We'll introduce changes via a PR so that our CI checks run and to give the release buddy an opporutnity to review.

### Update Version & Changelog

- [ ] Create a new branch from the latest commit on main
- [ ] Update CHANGELOG.md with a new section for this release, adding headlines & links for each included PR.
- [ ] Update the version number by running `./scripts/release/update-version.sh {VERSION}`.
- [ ] Open a pull request to main with these changes, have your release buddy review it, and merge it.

### Update the Release Branch

- [ ] Create a new branch off of the release branch.
- [ ] Copy patches from main into that branch.
    - This is usually accomplished via a git cherry-pick, but may need to be done manually if there are significant conflicts.
    - Always include the commit containing the version number and changelog updates.
    - Include other commits as needed based on the team's plan for what to include in the release.
- [ ] Open a pull request to the release branch with these changes, have your release buddy review it, and merge it.
    - This approach ensures that we run the exact code to be released through CI & a final peer review.

### Manual QA Part 1

- [ ] Examples App
    - Run the `mapbox-maps-ios` Examples app and make sure it's working
- [ ] [Studio Preview](https://github.com/mapbox/studio-preview-ios/)
    - Update the Podfile to point to the release branch:
        - `pod 'MapboxMaps', :git => 'https://github.com/mapbox/mapbox-maps-ios.git', :branch => 'release/v{MAJOR}.{MINOR}'`
    - Check for any breaking changes in the code and any visible performance issues.
- [ ] Verify installation via SPM.
    - Create a new single view app
    - Add `https://github.com/mapbox/mapbox-maps-ios.git` as a SPM dependency, specifying the release branch as the version requirement
    - Verify that you can display a basic map on device.

### Tag the Release

- [ ] Create a SEMVER tag on the release branch, and push the tag to GitHub:
    - `git tag {VERSION} && git push origin {VERSION}`
- [ ] Wait for the [release job](https://app.circleci.com/pipelines/github/mapbox/mapbox-maps-ios) to run. This job…
    - Builds the direct download artifacts for SDK Registry and uploads them to S3
    - Creates an [api-downloads PR](https://github.com/mapbox/api-downloads/pulls)
    - Builds the API docs (stored as an artifact of the CI job named `api-docs.zip`)
    - Creates a draft GitHub Release
- [ ] Push the release to CocoaPods via `$ pod trunk push`
- [ ] Update the [draft GitHub Release](https://github.com/mapbox/mapbox-maps-ios/releases).
    - The release notes should be more descriptive than `CHANGELOG.md`.
    - You can include information that developers will need to update successfully, organize the changes by theme, etc.
- [ ] If this is a beta or release candidate, check the prerelease box, otherwise uncheck it.
- [ ] Save your changes, but do not publish them, and have your release buddy review the draft.

### Manual QA Part 2

- [ ] Verify installation via direct download (dynamic).
    - Create a new single view app.
    - Download the dynamic artifact from SDK registry and follow the installation instructions in the enclosed `README.md`.
    - In the view controller, load a basic map view to ensure everything works as expected.
- [ ] Verify installation via direct download (static).
    - Create a new single view app.
    - Download the static artifact from SDK registry and follow the installation instructions in the enclosed `README.md`.
        - `https://api.mapbox.com/downloads/v2/mobile-maps-ios-static/releases/ios/<version-without-v-previx>/MapboxMaps-static.zip`
    - Verify that you can display a basic map on device.
- [ ] Verify installation via CocoaPods.
    - Create a new single view app
    - Close the Xcode project, run `pod init`, add `pod 'MapboxMaps', '{VERSION}'` to the Podfile, and run `pod install`
    - Verify that you can display a basic map on device.

## 📚 Update Documentation

### API Reference Docs

- [ ] Download `api-docs.zip` from the artifacts of the [release job](https://app.circleci.com/pipelines/github/mapbox/mapbox-maps-ios).
- [ ] In the `mapbox-maps-ios` repo, checkout branch `publisher-staging` and make sure it is up-to-date with `origin/publisher-staging` and `origin/publisher-production`.
    - If it is not, reset `publisher-staging` to point to the same commit as `origin/publisher-production` (while on `publisher-staging`, `$ git reset --hard origin/publisher-production`), and force push it to origin (`$ git push origin publisher-staging -f`).
- [ ] Make a new branch off of `publisher-staging`
- [ ] Unzip `api-docs.zip` and move the contents into our repo. This should result in a new top-level folder named after the version, but without the 'v' prefix.
- [ ] Download `MapboxCoreMaps-iOS-API-Reference.zip` from the corresponding `MapboxCoreMaps` [GitHub Release](https://github.com/mapbox/mapbox-gl-native-internal/releases).
- [ ] Download `ios-api-reference.zip` from the corresponding `MapboxCommon` [GitHub Release](https://github.com/mapbox/mapbox-sdk-common/releases).
- [ ] Unzip the docs via:
    - `unzip MapboxCoreMaps-iOS-API-Reference.zip -d core`
    - `unzip ios-api-reference.zip -d common`
- [ ] Move the unzipped directories `core` and `common` to the root of the Maps SDK docs for this version
- [ ] Open the `index.html` for this version of the MapboxMaps docs in a text editor. **NOTE: do not open index.html for `core` or `common`
- [ ] Navigate to the end of the `ul` tag which is embedded inside of the `nav` tag. This will be end of the navigation list. Append the follow html code to the list so that we can link the common and core documentation

```html
<li class="nav-group-name" data-name="Frameworks">
  <a class="small-heading" href="Frameworks.html">Frameworks<span class="anchor-icon" /></a>
  <ul class="nav-group-tasks">
    <li class="nav-group-task" data-name="MapboxCoreMaps">
      <a title="MapboxCoreMaps" class="nav-group-task-link" href="./core/index.html">MapboxCoreMaps</a>
    </li>
    <li class="nav-group-task" data-name="MapboxCommon">
      <a title="MapboxCommon" class="nav-group-task-link" href="./common/index.html">MapboxCommon</a>
    </li>
  </ul>
</li>
```

- [ ] Commit and push these changes.
- [ ] Make a pull request targeting `publisher-staging`.
- [ ] Share this with @mapbox/docs to approve.
- [ ] Merge the PR in `mapbox-maps-ios`.
- [ ] Preview the docs at the staging URL: https://docs.tilestream.net/ios/maps/api/{version_without_v_prefix}/index.html
- [ ] Create a PR to merge `publisher-staging` into `publisher-production`.
- [ ] Share the PR with @mapbox-docs to approve.
- [ ] Merge the PR. Do not use 'Squash and merge': this causes the publisher-staging and publisher-production branches to diverge. Merge manually using the command line if necessary.

### ios-sdk

- [ ] Create a `maps-{VERSION}` branch off of `publisher-production` in [ios-sdk](https://github.com/mapbox/ios-sdk).
- [ ] Add the new version (without a v prefix) as the first element in the [src/data/ios-maps-sdk-version.json](https://github.com/mapbox/ios-sdk/blob/publisher-production/src/data/ios-maps-sdk-versions.json).
- [ ] For non-prereleases, add the version without the v prefix to [src/constants.json](https://github.com/mapbox/ios-sdk/blob/publisher-production/src/constants.json) as the value for `MAPS_SDK_v10_VERSION_IOS`.
- [ ] Make sure the API Docs changes are live in production before continuing `https://docs.mapbox.com/ios/maps/api/{version_without_v_prefix}/index.html`
  - This is necessary because the CI checks triggered by the next step depend on them.
- [ ] Commit and push these changes, then open a PR.
- [ ] Ask your docs buddy to review it. Merge once approved!

## 📊 ZenHub

- [ ] Review the [issues in the ZenHub Release](https://app.zenhub.com/workspaces/maps-sdk-5fac44a73ae0870015ac174b/reports/release), adding or removing to the list as necessary.
- [ ] Close the Zenhub Release.

## 📣 Announce the Release

- [ ] Publish the [draft GitHub Release](https://github.com/mapbox/mapbox-maps-ios/releases).
- [ ] Announce the release in #sdk-releases to notify the team about the completed release! 🎉

## 🚀 Update Studio Preview

- [ ] Navigate to your local clone of [Studio Preview](https://github.com/mapbox/studio-preview-ios/) and ensure that it is up-to-date. Include any previous code updates that you made during QA.
- [ ] Release Studio Preview by following the steps outlined in the [Studio Preview iOS wiki](https://github.com/mapbox/studio-preview-ios/wiki/Release-Checklist).

When all of the above is completed, you can then close this ticket.
