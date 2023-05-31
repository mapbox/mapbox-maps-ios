<!-- PR description -->

## Pull request checklist:
 - [ ] Describe the changes in this PR, especially public API changes.
 - [ ] Include before/after visuals or gifs if this PR includes visual changes.
    <!--
        | Before | After |
        | ----- | ----- |
        | <img src="" width = 250/> | <img src="" width = 250/> |
        or
        | <video src="" width = 250/> | <video src="" width = 250/> |
    -->
 - [ ] Write tests for all new functionality. Put tests in correct Test Plan(mapbox-maps-ios/Tests/TestPlans) (Unit, Integration, All)
   - [ ] If tests were not written, please explain why.
 - [ ] Add documentation comments for any added or updated public APIs.
 - [ ] Add any new public, top-level symbols to the Jazzy config's `custom_categories` (mapbox-maps-ios/scripts/doc-generation/.jazzy.yaml)
 - [ ] Add a changelog entry to to bottom of the relevant section (typically the `## main`/`develop` heading near the top).
 - [ ] Update the guides, README.md, and DEVELOPING.md if their contents are impacted by these changes.
 - [ ] If this PR is a `v1x.[version]` release branch fix / enhancement, merge it to `main`/`develop` first and then port to the release branch.

PRs must be submitted under the terms of our Contributor License Agreement [CLA](https://github.com/mapbox/mapbox-maps-ios/blob/main/CONTRIBUTING.md#contributor-license-agreement).
