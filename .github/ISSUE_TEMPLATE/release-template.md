---
name: Release template — iOS stable
about: Checklist for a single release.
title: Release Maps v10 SDK <version>
labels: release
assignees: ''

---

# Stable release: <version>

- Releaser:
  - The releaser kicks off each step, tests the state of the SDK prior to and after the release, and updates the documentation. They should request their release and buddies the afternoon prior to the release.
- Release buddy:
  - The release buddy is on-hand to review PRs generated through the release process and to assist in troubleshooting the release.
- Docs buddy: 
  - The docs buddy reviews the documentation PR and assists with troubleshooting docs issues. 
- Release commencement time:
- SEMVER tag e.g `v10.0.0-rc.1`:
- Milestone:

## 📦 Release MapboxMaps

Notes: Unless otherwise specified, `VERSION` refers to the SEMVER tag with the `v` prefix.

Before you begin, check that the [MapboxCommon](https://github.com/mapbox/mapbox-sdk-common/releases) and [MapboxCoreMaps](https://github.com/mapbox/mapbox-core-maps-ios/releases) versions that you will use have been released and are available to download via CocoaPods and SPM. 

### Pull requests:
- [ ] mapbox-maps-ios release PR ->
- [ ] api-downloads PR ->
- [ ] mapbox-maps-ios docs PR ->
- [ ] ios-sdk PR ->
- [ ] studio-preview-ios PR ->
 
**1) Create Release Branch & Kickoff Build**

- [ ] Pull the latest from main to include all code updates. Then make a new branch called "Release/{VERSION}"
- [ ] Ensure you have `jq` installed: `$ brew install jq`
- [ ] Update the internal version pointers by running this command `./scripts/release/update-version.sh {VERSION}`. Commit these changes so they will be included in the build. This script also bumps the `maps_version` in MapboxMaps.podspec to match `VERSION`.
- [ ] Perform manual QA of this branch by running:
  - [ ] `mapbox-maps-ios` examples
  - [ ] [Studio Preview](https://github.com/mapbox/studio-preview-ios/). Update the Podfile to point to the release branch. Check for any breaking changes in the code and any visible performance issues.
- [ ] Verify installation via SPM. Open a tester single view application. Go to the Swift Package Manager menu and add our repo `https://github.com/mapbox/mapbox-maps-ios.git`. For the branch, specify the release branch. Then verify that you can load the SDK, and display a basic map on device to verify that the build is working.
- [ ] Open a PR for the "Release/{VERSION}" branch. This allows CI to run.
- [ ] Kickoff the build by passing an empty commit with the message "[release] {VERSION}", with the SEMVER version but no `v` prefix. For example: `git commit --allow-empty -m "[release] 10.0.0-rc.1"`. It's important that you follow the commit message as it triggers the build job.

***What will this job do?***

- Build our direct-download bundle
- Include LICENSE.md and README.md for bundle in the zip files
- Upload direct download to S3
- Create a PR [here](https://github.com/mapbox/api-downloads/pulls) so that our SDK can be consumed
- [ ] The API Downloads PR needs to be approved and merged before continuing. You do not need to merge your PR in `mapbox-maps-ios` yet.

**2) Update Distribution & Changelog**

- [ ] Generate the changelog manually by adding changes to the `CHANGELOG.md` file. Commit these changes have your release buddy review them. 
- [ ] Review issues [tagged with the Release](https://app.zenhub.com/workspaces/maps-sdk-for-ios-5e9f47ffdf1ce5046f9011f4/reports/release) adding or removing the release from the Zenhub issues as necessary.

**3) Create the Release Tag**

- [ ] Create a SEMVER tag, e.g. `vX.Y.Z-rc.N` and push the tag to GitHub: 
    - `git tag <version> && git push origin <version>`
    - This will trigger a CircleCI workflow that will produce the following artifacts (can be [found here](https://app.circleci.com/pipelines/github/mapbox/mapbox-maps-ios)):
        - an api-docs.zip
	- The completion of this job will make our api-docs which will be found in ci artifacts. It will also publish a GitHub draft release
- [ ] Push the release to CocoaPods via `$ pod trunk push`
- [ ] Update the information in the draft release with the correct changelog, versions, etc.
- [ ] Uncheck the prerelease box.
- [ ] Have your release buddy review the draft release, and save the draft. You will publish it in a later step.

**4) Confirm everything works as expected**

- [ ] Download the artifacts from the SDK registry. The zip file will include five xcframeworks. Create a new iOS application project in Xcode, and add all the frameworks. In the view controller, load a basic map view to ensure everything works as expected.
- [ ] Repeat the SDK registry testing for the static variant, available at `https://api.mapbox.com/downloads/v2/mobile-maps-ios-static/releases/ios/<version-without-v-previx>/MapboxMaps-static.zip`
- [ ] Test that consumption via CocoaPods works. SPM should have been verified at an earlier step

## 📚 Update documentation

- [ ] Navigate to the [CircleCI job page](https://app.circleci.com/pipelines/github/mapbox/mapbox-maps-ios), and download the `api-docs.zip` artifact.
- [ ] In the `mapbox-maps-ios` repo, `git checkout publisher-staging && git merge --no-ff origin/publisher-staging`. This is the branch that houses our API-Docs. Make a new branch off this one `git checkout -b Release/{version}_docs`
- [ ] Unzip the `api-docs.zip` and move the new docs into our repo. This should result in a new top-level folder named after the version, but without the 'v' prefix.

### Add framework docs

* Temporary step while we are working on more docs automation
- [ ] Find the `MapboxCoreMaps` [release](https://github.com/mapbox/mapbox-gl-native-internal/releases). Locate the version of `MapboxCoreMaps` being used in this release and download `MapboxCoreMaps-iOS-API-Reference.zip`.
- [ ] Find the `MapboxCommon` [release](https://github.com/mapbox/mapbox-sdk-common/releases). Locate the version of `MapboxCommon` being used in this release and download `ios-api-reference.zip`.
- [ ] unzip the docs using the following commands:
    - MapboxCoreMaps `unzip <path>/MapboxCoreMaps-iOS-API-Reference.zip -d core`
    - MapboxCommon `unzip <path>/ios-api-reference.zip -d common`
- [ ] Move the unzipped directories, `core` and `common` to the root of the Maps SDK docs that you moved at an earlier step
- [ ] Navigate to the Maps SDK docs and open `index.html` in a text editor. **NOTE: do not open index.html for `core` or `common`
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

### Commit and propogate doc changes

- [ ] Commit and push those changes.
- [ ] Make a pull request targeting the branch `publisher-staging`.
- [ ] Share this with @mapbox/docs to approve.
- [ ] Merge the PR in `mapbox-maps-ios`.
- [ ] Preview the docs at the staging URL: https://docs.tilestream.net/ios/maps/api/{version_without_v_prefix}/index.html
- [ ] Create a PR to merge `publisher-staging` into `publisher-production`.
- [ ] Share the PR with @mapbox-docs to approve.
- [ ] Merge the PR. Do not use 'Squash and merge': this causes the publisher-staging and publisher-production branches to diverge.
- [ ] Create a `maps-{VERSION}` branch in [ios-sdk](https://github.com/mapbox/ios-sdk).
- [ ] Add the new version (without a v prefix) as the first element in the [src/data/ios-maps-sdk-version.json](https://github.com/mapbox/ios-sdk/blob/publisher-production/src/data/ios-maps-sdk-versions.json).
- [ ] While the rc docs site is live and for subsequent stable releases, add the version without the v to [src/constants.json](https://github.com/mapbox/ios-sdk/blob/ios/maps-v10.0.0-beta.13.1/src/constants.json#L6) as the value for `MAPS_SDK_v10_VERSION_IOS`.
- [ ] Make sure the API Docs changes are live in production before continuing https://docs.mapbox.com/ios/maps/api/{version_without_v_prefix}/index.html
  - This is necessary because the CI checks triggered by the next step depend on them.
- [ ] Commit and push these changes, then open a PR.
- [ ] Ask your docs buddy to review it. Merge once approved!

## 🚢 Publish the release

- [ ] Publish the GitHub draft. The release is now done!

## 🚢 Merge your release branch

- [ ] Have your release buddy approve and then merge your release branch in `mapbox-maps-ios`.
***When you squash & merge, make the commit message "Maps SDK Release {Version}"***

## 🚀 Update Studio Preview
- [ ] Navigate to your local clone of [Studio Preview](https://github.com/mapbox/studio-preview-ios/) and ensure that it is up-to-date. Include any previous code updates that you made during QA.
- [ ] Release Studio Preview by following the steps outlined in the [Studio Preview iOS wiki](https://github.com/mapbox/studio-preview-ios/wiki/Release-Checklist).

## 📣 Announcements

- [ ] Tag the `@maps-ios` team in #mobile-maps-ios to notify the team about the completed release! 🎉
- [ ] Review (update if needed) the issues in the [Zenhub Release](https://app.zenhub.com/workspaces/maps-sdk-for-ios-5e9f47ffdf1ce5046f9011f4/reports/release) and close it.
- [ ] Announce the release in #sdk-releases and in #maps-sdk to notify the team about the completed release! 🎉

When all of the above is completed, you can then close this ticket.
