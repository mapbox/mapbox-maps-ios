# Map events

The simplified diagram of the events emitted by the map is displayed below.

![Map events sequence diagram](https://static-assets.mapbox.com/maps/ios/documentation/events.1c28dc5dac4025636a96175e2522d249c15c7441.svg)


## Topics

### Events
- ``MapLoaded``
- ``MapLoadingError``
- ``StyleLoaded``
- ``StyleDataLoaded``
- ``CameraChanged``
- ``MapIdle``
- ``SourceAdded``
- ``SourceRemoved``
- ``SourceDataLoaded``
- ``StyleImageMissing``
- ``StyleImageRemoveUnused``
- ``RenderFrameStarted``
- ``RenderFrameFinished``
- ``ResourceRequest``
- ``GenericEvent``

### Event payload
- ``StyleDataLoadedType``
- ``MapLoadingErrorType``
- ``SourceDataLoadedType``
- ``RenderModeType``
- ``RequestLoadingMethodType``
- ``RequestPriorityType``
- ``RequestResourceType``
- ``RequestDataSourceType``
- ``ResponseSourceType``

### Foundation

- ``Signal``
- ``AnyCancelable``
- ``Cancelable``
- ``EventTimeInterval``

### Extras

- ``ResourceRequestError``
- ``RequestInfo``
- ``ResponseInfo``

### Deprecated
- ``MapEventType``
