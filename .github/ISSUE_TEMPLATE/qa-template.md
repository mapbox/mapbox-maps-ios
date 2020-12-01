---
name: QA template — iOS
about: Checklist for quality assurance over a release cycle.
title: iOS Carbon Maps SDK Manual QA for <version>
labels: QA-testing
assignees: ''

---

# Maps Carbon SDK manual QA for `release-X`

### Instructions

- For each release or pre-release, the E2 engineer for that cycle should run all of the examples in the `[Examples app](https://github.com/mapbox/mapbox-maps-ios/tree/main/Examples)`. With each case, manually test panning, rotating, and tilting the map, selecting and deselecting annotations, etc. 

### Report format

When it is your turn to perform manual QA testing, please comment on this ticket with this format:

```
## X.Y.Z manual testing

**Device(s):**
**iOS versions(s):**

### Noted issues:
- List issues here, including a link to the corresponding GitHub ticket. See example below.
- Annotations flicker while panning [#321](https://github.com/mapbox/mapbox-maps-ios/issues/).

### Ongoing issues:
- List previously noted issues that you see during your testing.
```

/cc @mapbox/maps-ios
