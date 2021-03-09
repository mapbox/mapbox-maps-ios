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
- SEMVER tag e.g `v10.0.0-beta.12`:
- Milestone:

_Required dependencies:_

- Compatible version of MapboxCoreMaps:
- Compatible version of MapboxCommon:
- Compatible version of Xcode:
- Compatible version of MacOS:

## 📦 Release MapboxMaps

Notes: Unless otherwise specified, `VERSION` refers to the SEMVER tag with the `v` prefix.

Before you begin, check that the [MapboxCommon](https://github.com/mapbox/mapbox-sdk-common/releases) and [MapboxCoreMaps](https://github.com/mapbox/mapbox-core-maps-ios/releases) versions that you will use have been released and are available to download via CocoaPods and SPM. 

### Pull requests:
- [ ] mapbox-maps-ios release PR ->
- [ ] api-downloads PR ->
- [ ] mapbox-maps-ios docs PR ->
- [ ] ios-sdk PR ->
 
**1) Create Release Branch & Kickoff Build**

- [ ] Pull the latest from main to include all code updates. Then make a new branch called "Release/{VERSION}"
- [ ] Update the internal version pointers by running this command `./scripts/release/update-version.sh {VERSION}`. Commit these changes so they will be included in the build.
- [ ] Open a PR for the "Release/{VERSION}" branch. This allows CI to run.
- [ ] Kickoff the build by passing an empty commit with the message "[release] {VERSION}", with the SEMVER version but no `v` prefix. For example: `git commit --allow-empty -m "[release] 10.0.0-beta.14"`. It's important that you follow the commit message as it triggers the build job.

***What will this job do?***

- Build our direct-download bundle
- Include LICENSE.md and README.md for bundle in the zip files
- Upload direct download to S3
- Update the existing podspec and package manifest and commit that to the release branch
- Create a PR [here](https://github.com/mapbox/api-downloads/pulls) so that our SDK can be consumed
- [ ] The API Downloads PR needs to be approved and merged before continuing. You do not need to merge your PR in `mapbox-maps-ios` yet.

**2) Update Distribution & Changelog**

- [ ] On your local `Release/{VERSION}` branch, pull the latest from remote release branch. CI will have committed changes to podspec and package manifest.
- [ ] This is where we need to verify SPM update was successful. Open a tester single view application. Go to the Swift Package Manager menu and add our repo `https://github.com/mapbox/mapbox-maps-ios.git`. For the branch, specify your current release branch. Then verify that you can load the SDK, and display a basic map on device to verify that the build is working.
    - ***Note that the api-downloads PR needs to be merged and sanity checks need to complete before downloads are available here***
- [ ] Generate the changelog manually by addding changes to the `CHANGELOG.md` file. Commit these changes have your release buddy review them. 

**3) Create the Release Tag**

- [ ] Create a SEMVER tag, e.g. `vX.Y.Z-beta.N` and push the tag to GitHub: 
    - `git tag <version> && git push origin <version>`
    - This will trigger a CircleCI workflow that will produce the following artifacts (can be [found here](https://app.circleci.com/pipelines/github/mapbox/mapbox-maps-ios)):
        - an api-docs.zip
	- The completion of this job will make our api-docs which will be found in ci artifacts. It will also publish a GitHub draft release
- [ ] Push the release to CocoaPods via `$ pod trunk push`
- [ ] Update the information in the draft release with the correct changelog, versions, etc
- [ ] Have your release buddy review the draft release, and save the draft. You will publish it in a later step.

**4) Confirm everything works as expected**

- [ ] Download the artifacts from the SDK registry. The zip file will include five xcframeworks. Create a new iOS application project in Xcode, and add all the frameworks. In the view controller, load a basic map view to ensure everything works as expected.
- [ ] Test that consumption via CocoaPods works. SPM should have been verified at an earlier step

## 📚 Update documentation

- [ ] Navigate to the [CircleCI job page](https://app.circleci.com/pipelines/github/mapbox/mapbox-maps-ios), and download the `api-docs.zip` artifact.

- [ ] In the `mapbox-maps-ios` repo, `git checkout origin publisher-staging`. This is the branch that houses our API-Docs. Make a new branch off this one `git checkout -b Release/{version}_docs`
  - If you would like to test your API docs before publishing them, target the `publisher-staging` branch first, then once your PR lands there, cherry-pick your commit to a branch based on `publisher-production`.
- [ ] Unzip the `api-docs.zip` and move the new docs into our repo. 
- [ ] Commit and push those changes.
- [ ] Make a pull request targeting the branch `publisher-production`.
- [ ] Share this with @mapbox/docs to approve.
- [ ] Merge the PR in `mapbox-maps-ios`. Cherry-pick to the `publisher-production`
- [ ] Create a `maps-{VERSION}` branch in [ios-sdk](https://github.com/mapbox/ios-sdk).
- [ ] Add the new version (without a v prefix) as the first element in the [src/data/ios-maps-sdk-version.json](https://github.com/mapbox/ios-sdk/blob/publisher-production/src/data/ios-maps-sdk-versions.json).
- [ ] While the beta docs site is live and for subsequent stable releases, add the version without the v to [src/constants.json](https://github.com/mapbox/ios-sdk/blob/ios/maps-v10.0.0-beta.13.1/src/constants.json#L6) as the value for `VERSION_IOS_MAPS_SDK_V10`.
- [ ] Commit and push these changes, then open a PR.
- [ ] Ask your docs buddy to review it. Merge once approved!

## 🚢 Publish the release

- [ ] Publish the GitHub draft. The release is now done!

## 🚢 Merge your release branch

- [ ] Have your release buddy approve and then merge your release branch in `mapbox-maps-ios`.
***When you squash & merge, make the commit message "Maps SDK Release {Version}"***

## 📣 Announcements

- [ ] Tag the `@maps-ios` team in #mobile-maps-ios to notify the team about the completed release! 🎉

When all of the above is completed, you can then close this ticket.
