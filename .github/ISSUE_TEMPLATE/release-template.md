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
- Release commencement time:
- Semantic Version (referred to hereafter as `VERSION`) e.g `v10.0.0-rc.1`:

## Before You Begin

- [ ] Verify that the [MapboxCommon](https://github.com/mapbox/mapbox-sdk-common/releases) and [MapboxCoreMaps](https://github.com/mapbox/mapbox-core-maps-ios/releases) versions that you will use have been released and are available to download via CocoaPods and SPM.
- [ ] Ensure you have `jq` installed: `$ brew install jq`

### Pull requests:
CircleCI Release workflow: <circleci-url>

- [ ] mapbox-maps-ios version & changlog updates on main ->
- [ ] mapbox-maps-ios release branch updates ->
- [ ] api-downloads ->
- [ ] mapbox-maps-ios production docs ->
- [ ] ios-sdk ->
- [ ] studio-preview-ios ->

## 📦 Release MapboxMaps

### Create the Release Branch

Only create a release branch for RC and final releases. Beta releases may be tagged on the main branch.

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
    
### Tag the Release

- [ ] Create a SEMVER tag on the release branch, and push the tag to GitHub:
    - `git tag {VERSION} && git push origin {VERSION}`
    - This triggers the [release workflow](https://app.circleci.com/pipelines/github/mapbox/mapbox-maps-ios) which automates most of the release actions.
- [ ] Review and merge the api-downloads PR.
    - [ ] Approve `wait-registry-pr` job in CircleCI release workflow.
- [ ] Review and merge the mapbox-maps-ios@publisher-production PR.
- [ ] Wait for mapbox-maps-ios@publisher-production PR be merged.
- [ ] Review and merge the ios-sdk PR.
- [ ] Update the [draft GitHub Release](https://github.com/mapbox/mapbox-maps-ios/releases)
    - Draft may include the latest changelog entries and links to dependencies releases. Please, replace that content with more descritive release notes. It's also make sense to copy-paste public changelog from gl-native-internal.
    - You can include information that developers will need to update successfully, organize the changes by theme, etc.
    - If this is a beta or release candidate, check the prerelease box, otherwise uncheck it.
    - Save your changes, but do not publish them, and have your release buddy review the draft.

## 📊 GitHub Projects

- [ ] Review the [issues in the GitHub Projects Release](https://github.com/orgs/mapbox/projects/707/views/7), adding or removing to the list as necessary.

## 📣 Announce the Release

- [ ] Publish the [draft GitHub Release](https://github.com/mapbox/mapbox-maps-ios/releases).
- [ ] Announce the release in #sdk-releases to notify the team about the completed release! 🎉

## 🚀 Update Studio Preview

- [ ] Navigate to your local clone of [Studio Preview](https://github.com/mapbox/studio-preview-ios/) and ensure that it is up-to-date. Include any previous code updates that you made during QA.
- [ ] Release Studio Preview by following the steps outlined in the [Studio Preview iOS wiki](https://github.com/mapbox/studio-preview-ios/wiki/Release-Checklist).

When all of the above is completed, you can then close this ticket.
