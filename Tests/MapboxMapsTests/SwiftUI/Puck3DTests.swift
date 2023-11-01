import XCTest
@_spi(Experimental) @testable import MapboxMaps

@available(iOS 13.0, *)
final class Puck3DTests: XCTestCase {

    func testVisit() {
        let model = Model()

        let puck = Puck3D(model: model, bearing: nil)
            .modelCastShadows(.testConstantValue())
            .modelOpacity(.testConstantValue())
            .modelReceiveShadows(.testConstantValue())
            .modelRotation(.testConstantValue())
            .modelScale(.testConstantValue())
            .modelScaleMode(.testConstantValue())
            .modelEmissiveStrength(5)

        let visitor = DefaultMapContentVisitor()
        puck.visit(visitor)

        var expectedPuckConfig = Puck3DConfiguration(model: model)
        expectedPuckConfig.modelCastShadows = .constant(.testConstantValue())
        expectedPuckConfig.modelOpacity = .constant(.testConstantValue())
        expectedPuckConfig.modelReceiveShadows = .constant(.testConstantValue())
        expectedPuckConfig.modelRotation = .constant(.testConstantValue())
        expectedPuckConfig.modelScale = .constant(.testConstantValue())
        expectedPuckConfig.modelScaleMode = .testConstantValue()
        expectedPuckConfig.modelEmissiveStrength = .constant(5)

        XCTAssertEqual(visitor.locationOptions, .init(puckType: .puck3D(expectedPuckConfig), puckBearingEnabled: false))
    }
}
