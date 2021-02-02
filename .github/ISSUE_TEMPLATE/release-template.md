---
name: Release template — iOS stable
about: Checklist for a single release.
title: Release Maps v10 SDK <version>
labels: release
assignees: ''

---

# Stable release: <version>

- Releaser:
- Release buddy:
- Release commencement time:
- SEMVER tag e.g `v10.0.0-beta.12`:
- Milestone:

_Required dependencies:_

- Compatible version of MapboxCoreMaps:
- Compatible version of MapboxCommon:
- Compatible version of Xcode:
- Compatible version of MacOS:

## 📦 Verify Dependencies

- [ ] Verify the Cartfile for correct version of MapboxCoreMaps
- [ ] Verify the Cartfile for correct version of MapboxCommon
- [ ] Verify the Cartfile for correct version of Turf
- [ ] Verify the Cartfile for correct version of MME

## 📦 Release MapboxMaps

**1) Create Release Branch & Kickoff Build**

- [ ] Pull the latest from main to include all code updates. Then make a new branch called "Release/{VERSION}"
- [ ] Kickoff the build by passing an empty commit with the message "[release] {VERSION}". Please copy this command to use an empty commit `git commit --allow-empty -m "[release] {VERSION}"` <-- do not include the "v" in version here
- **It's important that you follow the commit message. This is what triggers the build job

***What will this job do?***

- Build our xcframework and our direct-download bundle
- Include LICENSE.md in the zip files
- Upload direct download and xcframework to S3
- Store the checksum of the .xcframework.zip as a CI artifact
- Create a PR [here](https://github.com/mapbox/api-downloads/pulls) so that our SDK can be consumed
- [ ] The above PR needs to be approved and merged before continuing

**2) Update Distribution & Changelog**

- [ ] From the previous job, go to the CI Artifacts and get the value from the `MapboxMaps.xcframework.zip.checksum`. This will be needed to update SPM
- [ ] On your release branch, run the update manifest script `./scripts/update-spm-manifest.sh <maps version number> <common version number> <core version number> <maps xcframework checksum>`
- [ ] The above script will update `Package.swift`. Open the file and verify the changes are correct and then push this commit to remote
- [ ] This is where we need to verify SPM update was successful. Open a tester single view application. Go to the Swift Package Manager menu and add our repo `https://github.com/mapbox/mapbox-maps-ios.git`. For the branch, specify your current release branch. Then verify that you can load the SDK, and display a basic map on device to verify that the build is working.
    - ***Note that the api-downloads PR needs to be merged and sanity checks need to complete before downloads are available here***
- [ ] Generate the changelog by running the following script `./scripts/release/generate_changelog.sh`
- [ ] Update the changelog as needed and push those changes

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
- [ ] Move and rename this zip file to Google Drive in Mobile Maps SDK/Public/Carbon Docs (PUBLIC)/maps-ios-`<version>`.zip.
- [ ] Package the Examples workspace as a zip and upload it to Google Drive in Mobile Maps SDK/Public/Carbon Docs

## 🚢 Publish the release

- [ ] Publish the GitHub draft. The release is now done!

## 🚢 Merge your release branch

- [ ] Create a pull request from your release branch which targets `main`.
- [ ] Have your release buddy approve and then merge it

## 📣 Announcements

- [ ] Tag the `@maps-ios` team in #mobile-maps-ios to notify the team about the completed release! 🎉

// TODO: Slackbot alert from GitHub release?

When all of the above is completed, you can then close this ticket.
