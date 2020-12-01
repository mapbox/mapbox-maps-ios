---
name: Release template — iOS stable
about: Checklist for a single release.
title: Release Maps Carbon SDK <version> (<codename>)
labels: release
assignees: ''

---

# Stable release: <version>

- Releaser:
- Release buddy:
- Release commencement time:
- SEMVER tag/`<version>`:
- Milestone:

_Required dependencies:_

- Compatible version of MapboxCoreMaps:
- Compatible version of MapboxCommon:
- Compatible version of Xcode:
- Compatible version of MacOS:

## 📦 Release MapboxCoreMaps

- [ ] Release MapboxCoreMaps, if needed.
    * If necessary, [follow these instructions](https://github.com/mapbox/mapbox-gl-native-ios-internal#how-to-build-mapboxcoremaps-used-in-carbon-releases) to do so. 

## 📦 Release MapboxMaps

**1) Create the release tag**

- [ ] Create a SEMVER tag, e.g. `X.Y.Z-beta.N` and push the tag to GitHub: 
    - `git tag <version> && git push origin <version>`
        - NOTE: We are NOT using release branches at this moment, so perform the tag on `main`.
    - This will trigger a CircleCI workflow that will produce the following artifacts (can be [found here](https://app.circleci.com/pipelines/github/mapbox/mapbox-maps-ios)):
        - a zip containing the 5 xcframeworks
        - an api-docs.zip
    - The artifacts will also be automatically uploaded to AWS S3 to prepare them to be hosted on the SDK registry.
    
**NOTE** This should be the only step you need to do, other than reviewing/merging PRs. The remaining steps are a reference in case automation fails

**2) Draft the GitHub release**

* This is included in automation. Once the CI job has completed, a new draft release will be made [here](https://github.com/mapbox/mapbox-maps-ios/releases)
* Update the release notes with changelog items (TODO: Automate this)

**If Manual Release Is Needed**
- [ ] While the CI job is in progress, prepare the GitHub release by creating a draft release on Github, based off the new tag you created. In the release description, include the following template: 

````

### Dependency requirements:

* Compatible version of MapboxCoreMaps:
* Compatible version of MapboxCommon:
* Compatible version of Xcode:
* Compatible version of MacOS:

### Changes

<Copy and paste CHANGELOG.MD>

[See changes since <previous version>](https://github.com/mapbox/mapbox-maps-ios/compare/<previous version>>...<version>)

### Direct download

Link to download binaries (append your own Mapbox access token [scoped with `DOWNLOADS:READ`](https://account.mapbox.com/)):

```
https://api.mapbox.com/downloads/v2/mobile-maps-ios-privatebeta/releases/ios/<version>/mapbox-maps-ios-privatebeta.zip?access_token=<access-token>
```
````

- [ ] Then, have your release buddy review the draft release, and save the draft. You will publish it in a later step.

**3) Release binaries to SDK registry**

* This is included in automation. Once the CI job has completed, a pr will be made [here](https://github.com/mapbox/api-downloads/pulls)

**If Manual Release Is Needed**
- [ ] Next, trigger the creation of a PR to `api-downloads` with the configurations needed to host the artifacts on the SDK registry by running the following script:

```
./scripts/release/create-api-downloads-pr.sh mobile-maps-ios-privatebeta <version> mapbox-maps-ios-privatebeta <link to this release ticket>
```

- [ ] Have your release buddy approve this PR and then merge it.

**4) Confirm everything works as expected**

- [ ] Download the artifacts from the SDK registry. The zip file will include five xcframeworks. Create a new iOS application project in Xcode, and add all the frameworks. In the view controller, load a basic map view to ensure everything works as expected.

## 📚 Update documentation

- [ ] Navigate to the [CircleCI job page](https://app.circleci.com/pipelines/github/mapbox/mapbox-maps-ios), and download the `api-docs.zip` artifact.
- [ ] Move and rename this zip file to Google Drive in Mobile Maps SDK/Public/Carbon Docs (PUBLIC)/maps-ios-`<version>`.zip.

## 🚢 Publish the release

- [ ] Publish the GitHub draft. The release is now done!

## 📣 Announcements

- [ ] Tag the `@maps-ios` team in #mobile-maps-ios to notify the team about the completed release! 🎉

// TODO: Slackbot alert from GitHub release?

When all of the above is completed, you can then close this ticket.
