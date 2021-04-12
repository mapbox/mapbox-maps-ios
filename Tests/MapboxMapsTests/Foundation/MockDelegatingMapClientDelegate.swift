@testable import MapboxMaps

final class MockDelegatingMapClientDelegate: DelegatingMapClientDelegate {
    let scheduleRepaintStub = Stub<Void, Void>()
    func scheduleRepaint() {
        scheduleRepaintStub.call()
    }

    let scheduleTaskStub = Stub<Task, Void>()
    func scheduleTask(forTask task: @escaping Task) {
        scheduleTaskStub.call(with: task)
    }

    let getMetalViewStub = Stub<MTLDevice?, MTKView?>(defaultReturnValue: nil)
    func getMetalView(for metalDevice: MTLDevice?) -> MTKView? {
        return getMetalViewStub.call(with: metalDevice)
    }
}
