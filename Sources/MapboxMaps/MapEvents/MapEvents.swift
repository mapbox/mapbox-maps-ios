import MapboxCoreMaps
import Foundation
import MapboxCommon

/// Converts events API  from `MapboxMapsCore.Observable` to `Signal`s.
internal final class MapEvents {
    internal typealias GenericSubjectFactory = (String) -> SignalSubject<GenericEvent>

    let onMapLoaded: SignalSubject<MapLoaded>
    let onMapLoadingError: SignalSubject<MapLoadingError>
    let onStyleLoaded: SignalSubject<StyleLoaded>
    let onStyleDataLoaded: SignalSubject<StyleDataLoaded>
    let onCameraChanged: SignalSubject<CameraChanged>
    let onMapIdle: SignalSubject<MapIdle>
    let onSourceAdded: SignalSubject<SourceAdded>
    let onSourceRemoved: SignalSubject<SourceRemoved>
    let onSourceDataLoaded: SignalSubject<SourceDataLoaded>
    let onStyleImageMissing: SignalSubject<StyleImageMissing>
    let onStyleImageRemoveUnused: SignalSubject<StyleImageRemoveUnused>
    let onRenderFrameStarted: SignalSubject<RenderFrameStarted>
    let onRenderFrameFinished: SignalSubject<RenderFrameFinished>
    let onResourceRequest: SignalSubject<ResourceRequest>
    let makeGenericSubject: (String) -> SignalSubject<GenericEvent>

    private var genericSubjects = [String: SignalSubject<GenericEvent>]()
    var cancelables = Set<AnyCancelable>()

    init(observable: CoreObservable) {
        onMapLoaded = .from(method: observable.subscribe(forMapLoaded:))
        onMapLoadingError = .from(method: observable.subscribe(forMapLoadingError:))
        onStyleLoaded = .from(method: observable.subscribe(forStyleLoaded:))
        onStyleDataLoaded = .from(method: observable.subscribe(forStyleDataLoaded:))
        onCameraChanged = .from(method: observable.subscribe(forCameraChanged:))
        onMapIdle = .from(method: observable.subscribe(forMapIdle:))
        onSourceAdded = .from(method: observable.subscribe(forSourceAdded:))
        onSourceRemoved = .from(method: observable.subscribe(forSourceRemoved:))
        onSourceDataLoaded = .from(method: observable.subscribe(forSourceDataLoaded:))
        onStyleImageMissing = .from(method: observable.subscribe(forStyleImageMissing:))
        onStyleImageRemoveUnused = .from(method: observable.subscribe(forStyleImageRemoveUnused:))
        onRenderFrameStarted = .from(method: observable.subscribe(forRenderFrameStarted:))
        onRenderFrameFinished = .from(method: observable.subscribe(forRenderFrameFinished:))
        onResourceRequest = .from(method: observable.subscribe(forResourceRequest:))
        makeGenericSubject = { eventName in
            .from(parameter: eventName, method: observable.subscribe(forEventName:callback:))
        }
    }

    // For use in tests only
    internal init(makeGenericSubject: @escaping GenericSubjectFactory) {
        onMapLoaded = SignalSubject()
        onMapLoadingError = SignalSubject()
        onStyleLoaded = SignalSubject()
        onStyleDataLoaded = SignalSubject()
        onCameraChanged = SignalSubject()
        onMapIdle = SignalSubject()
        onSourceAdded = SignalSubject()
        onSourceRemoved = SignalSubject()
        onSourceDataLoaded = SignalSubject()
        onStyleImageMissing = SignalSubject()
        onStyleImageRemoveUnused = SignalSubject()
        onRenderFrameStarted = SignalSubject()
        onRenderFrameFinished = SignalSubject()
        onResourceRequest = SignalSubject()
        self.makeGenericSubject = makeGenericSubject
    }

    func signal<T>(for keyPath: KeyPath<MapEvents, SignalSubject<T>>) -> Signal<T> {
        return self[keyPath: keyPath].signal
    }

    /// Subscribes to a generic event by a string name.
    /// This method is reserved for the future use.
    subscript(eventName: String) -> Signal<GenericEvent> {
        let subject: SignalSubject<GenericEvent>
        if let subj = genericSubjects[eventName] {
            subject = subj
        } else {
            subject = makeGenericSubject(eventName)
            genericSubjects[eventName] = subject
        }
        return subject.signal
    }
}
