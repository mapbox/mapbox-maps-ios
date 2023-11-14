# Map events

The simplified diagram of the events emitted by the map is displayed below.
```
┌─────────────┐               ┌─────────┐                   ┌──────────────┐
│ Application │               │   Map   │                   │ResourceLoader│
└──────┬──────┘               └────┬────┘                   └───────┬──────┘
       │                           │                                │
       ├───────setStyleURI────────▶│                                │
       │                           ├───────────get style───────────▶│
       │                           │                                │
       │                           │◀─────────style data────────────┤
       │                           │                                │
       │                           ├─parse style─┐                  │
       │                           │             │                  │
       │      StyleDataLoaded      ◀─────────────┘                  │
       │◀───────type: Style────────┤                                │
       │                           ├─────────get sprite────────────▶│
       │                           │                                │
       │                           │◀────────sprite data────────────┤
       │                           │                                │
       │                           ├──────parse sprite───────┐      │
       │                           │                         │      │
       │      StyleDataLoaded      ◀─────────────────────────┘      │
       │◀──────type: Sprite────────┤                                │
       │                           ├─────get source TileJSON(s)────▶│
       │                           │                                │
       │     SourceDataLoaded      │◀─────parse TileJSON data───────┤
       │◀─────type: Metadata───────┤                                │
       │                           │                                │
       │                           │                                │
       │      StyleDataLoaded      │                                │
       │◀──────type: Sources───────┤                                │
       │                           ├──────────get tiles────────────▶│
       │                           │                                │
       │◀───────StyleLoaded────────┤                                │
       │                           │                                │
       │     SourceDataLoaded      │◀─────────tile data─────────────┤
       │◀───────type: Tile─────────┤                                │
       │                           │                                │
       │                           │                                │
       │◀────RenderFrameStarted────┤                                │
       │                           ├─────render─────┐               │
       │                           │                │               │
       │                           ◀────────────────┘               │
       │◀───RenderFrameFinished────┤                                │
       │                           ├──render, all tiles loaded──┐   │
       │                           │                            │   │
       │                           ◀────────────────────────────┘   │
       │◀────────MapLoaded─────────┤                                │
       │                           │                                │
       │                           │                                │
       │◀─────────MapIdle──────────┤                                │
       │                    ┌ ─── ─┴─ ─── ┐                         │
       │                    │   offline   │                         │
       │                    └ ─── ─┬─ ─── ┘                         │
       │                           │                                │
       ├─────────setCamera────────▶│                                │
       │                           ├───────────get tiles───────────▶│
       │                           │                                │
       │                           │┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─   │
       │◀─────────MapIdle──────────┤   waiting for connectivity  │  │
       │                           ││  Map renders cached data      │
       │                           │ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘  │
       │                           │                                │
```


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
