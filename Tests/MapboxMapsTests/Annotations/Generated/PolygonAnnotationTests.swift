// This file is generated
import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class PolygonAnnotationTests: XCTestCase {

    func testFillConstructBridgeGuardRail() {
        let polygonCoords = [
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
        ]
        var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)), isSelected: false, isDraggable: false)
        annotation.fillConstructBridgeGuardRail =  Bool.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .boolean(fillConstructBridgeGuardRail) = layerProperties["fill-construct-bridge-guard-rail"] else {
            return XCTFail("Layer property fill-construct-bridge-guard-rail should be set to a boolean.")
        }
        XCTAssertEqual(fillConstructBridgeGuardRail, annotation.fillConstructBridgeGuardRail)
    }

    func testFillSortKey() {
        let polygonCoords = [
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
        ]
        var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)), isSelected: false, isDraggable: false)
        annotation.fillSortKey =  Double.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .number(fillSortKey) = layerProperties["fill-sort-key"] else {
            return XCTFail("Layer property fill-sort-key should be set to a number.")
        }
        XCTAssertEqual(fillSortKey, annotation.fillSortKey)
    }

    func testFillBridgeGuardRailColorUseTheme() {
      let polygonCoords = [
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
        ]
        var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)), isSelected: false, isDraggable: false)
      annotation.fillBridgeGuardRailColorUseTheme = .default

      guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
          return
      }
      guard case let .object(layerProperties) = featureProperties["layerProperties"],
            case let .string(fillBridgeGuardRailColorUseTheme) = layerProperties["fill-bridge-guard-rail-color-use-theme"] else {
          return XCTFail("Layer property fill-bridge-guard-rail-color-use-theme should be set to a string.")
      }

      XCTAssertEqual(fillBridgeGuardRailColorUseTheme, annotation.fillBridgeGuardRailColorUseTheme?.rawValue)
    }
    func testFillBridgeGuardRailColorTransition() {
        let polygonCoords = [
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
        ]
        var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)), isSelected: false, isDraggable: false)
        annotation.fillBridgeGuardRailColorTransition = StyleTransition(duration: 1, delay: 1)

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .object(fillBridgeGuardRailColorTransition) = layerProperties["fill-bridge-guard-rail-color-transition"],
              case let .number(duration) = fillBridgeGuardRailColorTransition["duration"],
              case let .number(delay) = fillBridgeGuardRailColorTransition["delay"]
        else {
            return XCTFail("Layer property fill-bridge-guard-rail-color-transition should be set to a string.")
        }

        XCTAssertEqual(duration / 1000, annotation.fillBridgeGuardRailColorTransition?.duration)
        XCTAssertEqual(delay / 1000, annotation.fillBridgeGuardRailColorTransition?.delay)
    }

    func testFillBridgeGuardRailColor() {
        let polygonCoords = [
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
        ]
        var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)), isSelected: false, isDraggable: false)
        annotation.fillBridgeGuardRailColor =  StyleColor.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .string(fillBridgeGuardRailColor) = layerProperties["fill-bridge-guard-rail-color"] else {
            return XCTFail("Layer property fill-bridge-guard-rail-color should be set to a string.")
        }
        XCTAssertEqual(fillBridgeGuardRailColor, annotation.fillBridgeGuardRailColor.flatMap { $0.rawValue })
    }

    func testFillColorUseTheme() {
      let polygonCoords = [
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
        ]
        var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)), isSelected: false, isDraggable: false)
      annotation.fillColorUseTheme = .default

      guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
          return
      }
      guard case let .object(layerProperties) = featureProperties["layerProperties"],
            case let .string(fillColorUseTheme) = layerProperties["fill-color-use-theme"] else {
          return XCTFail("Layer property fill-color-use-theme should be set to a string.")
      }

      XCTAssertEqual(fillColorUseTheme, annotation.fillColorUseTheme?.rawValue)
    }
    func testFillColorTransition() {
        let polygonCoords = [
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
        ]
        var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)), isSelected: false, isDraggable: false)
        annotation.fillColorTransition = StyleTransition(duration: 1, delay: 1)

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .object(fillColorTransition) = layerProperties["fill-color-transition"],
              case let .number(duration) = fillColorTransition["duration"],
              case let .number(delay) = fillColorTransition["delay"]
        else {
            return XCTFail("Layer property fill-color-transition should be set to a string.")
        }

        XCTAssertEqual(duration / 1000, annotation.fillColorTransition?.duration)
        XCTAssertEqual(delay / 1000, annotation.fillColorTransition?.delay)
    }

    func testFillColor() {
        let polygonCoords = [
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
        ]
        var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)), isSelected: false, isDraggable: false)
        annotation.fillColor =  StyleColor.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .string(fillColor) = layerProperties["fill-color"] else {
            return XCTFail("Layer property fill-color should be set to a string.")
        }
        XCTAssertEqual(fillColor, annotation.fillColor.flatMap { $0.rawValue })
    }

    func testFillOpacityTransition() {
        let polygonCoords = [
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
        ]
        var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)), isSelected: false, isDraggable: false)
        annotation.fillOpacityTransition = StyleTransition(duration: 1, delay: 1)

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .object(fillOpacityTransition) = layerProperties["fill-opacity-transition"],
              case let .number(duration) = fillOpacityTransition["duration"],
              case let .number(delay) = fillOpacityTransition["delay"]
        else {
            return XCTFail("Layer property fill-opacity-transition should be set to a string.")
        }

        XCTAssertEqual(duration / 1000, annotation.fillOpacityTransition?.duration)
        XCTAssertEqual(delay / 1000, annotation.fillOpacityTransition?.delay)
    }

    func testFillOpacity() {
        let polygonCoords = [
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
        ]
        var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)), isSelected: false, isDraggable: false)
        annotation.fillOpacity =  Double.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .number(fillOpacity) = layerProperties["fill-opacity"] else {
            return XCTFail("Layer property fill-opacity should be set to a number.")
        }
        XCTAssertEqual(fillOpacity, annotation.fillOpacity)
    }

    func testFillOutlineColorUseTheme() {
      let polygonCoords = [
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
        ]
        var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)), isSelected: false, isDraggable: false)
      annotation.fillOutlineColorUseTheme = .default

      guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
          return
      }
      guard case let .object(layerProperties) = featureProperties["layerProperties"],
            case let .string(fillOutlineColorUseTheme) = layerProperties["fill-outline-color-use-theme"] else {
          return XCTFail("Layer property fill-outline-color-use-theme should be set to a string.")
      }

      XCTAssertEqual(fillOutlineColorUseTheme, annotation.fillOutlineColorUseTheme?.rawValue)
    }
    func testFillOutlineColorTransition() {
        let polygonCoords = [
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
        ]
        var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)), isSelected: false, isDraggable: false)
        annotation.fillOutlineColorTransition = StyleTransition(duration: 1, delay: 1)

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .object(fillOutlineColorTransition) = layerProperties["fill-outline-color-transition"],
              case let .number(duration) = fillOutlineColorTransition["duration"],
              case let .number(delay) = fillOutlineColorTransition["delay"]
        else {
            return XCTFail("Layer property fill-outline-color-transition should be set to a string.")
        }

        XCTAssertEqual(duration / 1000, annotation.fillOutlineColorTransition?.duration)
        XCTAssertEqual(delay / 1000, annotation.fillOutlineColorTransition?.delay)
    }

    func testFillOutlineColor() {
        let polygonCoords = [
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
        ]
        var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)), isSelected: false, isDraggable: false)
        annotation.fillOutlineColor =  StyleColor.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .string(fillOutlineColor) = layerProperties["fill-outline-color"] else {
            return XCTFail("Layer property fill-outline-color should be set to a string.")
        }
        XCTAssertEqual(fillOutlineColor, annotation.fillOutlineColor.flatMap { $0.rawValue })
    }

    func testFillPattern() {
        let polygonCoords = [
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
        ]
        var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)), isSelected: false, isDraggable: false)
        annotation.fillPattern =  String.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .string(fillPattern) = layerProperties["fill-pattern"] else {
            return XCTFail("Layer property fill-pattern should be set to a string.")
        }
        XCTAssertEqual(fillPattern, annotation.fillPattern)
    }

    func testFillTunnelStructureColorUseTheme() {
      let polygonCoords = [
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
        ]
        var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)), isSelected: false, isDraggable: false)
      annotation.fillTunnelStructureColorUseTheme = .default

      guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
          return
      }
      guard case let .object(layerProperties) = featureProperties["layerProperties"],
            case let .string(fillTunnelStructureColorUseTheme) = layerProperties["fill-tunnel-structure-color-use-theme"] else {
          return XCTFail("Layer property fill-tunnel-structure-color-use-theme should be set to a string.")
      }

      XCTAssertEqual(fillTunnelStructureColorUseTheme, annotation.fillTunnelStructureColorUseTheme?.rawValue)
    }
    func testFillTunnelStructureColorTransition() {
        let polygonCoords = [
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
        ]
        var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)), isSelected: false, isDraggable: false)
        annotation.fillTunnelStructureColorTransition = StyleTransition(duration: 1, delay: 1)

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .object(fillTunnelStructureColorTransition) = layerProperties["fill-tunnel-structure-color-transition"],
              case let .number(duration) = fillTunnelStructureColorTransition["duration"],
              case let .number(delay) = fillTunnelStructureColorTransition["delay"]
        else {
            return XCTFail("Layer property fill-tunnel-structure-color-transition should be set to a string.")
        }

        XCTAssertEqual(duration / 1000, annotation.fillTunnelStructureColorTransition?.duration)
        XCTAssertEqual(delay / 1000, annotation.fillTunnelStructureColorTransition?.delay)
    }

    func testFillTunnelStructureColor() {
        let polygonCoords = [
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
        ]
        var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)), isSelected: false, isDraggable: false)
        annotation.fillTunnelStructureColor =  StyleColor.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .string(fillTunnelStructureColor) = layerProperties["fill-tunnel-structure-color"] else {
            return XCTFail("Layer property fill-tunnel-structure-color should be set to a string.")
        }
        XCTAssertEqual(fillTunnelStructureColor, annotation.fillTunnelStructureColor.flatMap { $0.rawValue })
    }

    func testFillZOffsetTransition() {
        let polygonCoords = [
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
        ]
        var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)), isSelected: false, isDraggable: false)
        annotation.fillZOffsetTransition = StyleTransition(duration: 1, delay: 1)

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .object(fillZOffsetTransition) = layerProperties["fill-z-offset-transition"],
              case let .number(duration) = fillZOffsetTransition["duration"],
              case let .number(delay) = fillZOffsetTransition["delay"]
        else {
            return XCTFail("Layer property fill-z-offset-transition should be set to a string.")
        }

        XCTAssertEqual(duration / 1000, annotation.fillZOffsetTransition?.duration)
        XCTAssertEqual(delay / 1000, annotation.fillZOffsetTransition?.delay)
    }

    func testFillZOffset() {
        let polygonCoords = [
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
        ]
        var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)), isSelected: false, isDraggable: false)
        annotation.fillZOffset =  Double.testConstantValue()

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else {
            return
        }
        guard case let .object(layerProperties) = featureProperties["layerProperties"],
              case let .number(fillZOffset) = layerProperties["fill-z-offset"] else {
            return XCTFail("Layer property fill-z-offset should be set to a number.")
        }
        XCTAssertEqual(fillZOffset, annotation.fillZOffset)
    }

    @available(*, deprecated)
    func testUserInfo() throws {
        let polygonCoords = [
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
        ]
        var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)), isSelected: false, isDraggable: false)
        let userInfo = ["foo": "bar"]
        annotation.userInfo = userInfo

        let featureProperties = try XCTUnwrap(annotation.feature.properties)
        let actualUserInfo = try XCTUnwrap(featureProperties["userInfo"]??.rawValue as? [String: Any])
        XCTAssertEqual(actualUserInfo["foo"] as? String, userInfo["foo"])
    }

    @available(*, deprecated)
    func testUserInfoNilWhenNonJSONObjectPassed() throws {
        struct NonJSON: Equatable {}
        let polygonCoords = [
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
        ]
        var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)), isSelected: false, isDraggable: false)
        annotation.userInfo = ["foo": NonJSON()]

        let featureProperties = try XCTUnwrap(annotation.feature.properties)
        let actualUserInfo = try XCTUnwrap(featureProperties["userInfo"]??.rawValue as? [String: Any])
        XCTAssertNil(actualUserInfo["foo"] as? NonJSON)
    }

    @available(*, deprecated)
    func testCustomData() throws {
        let polygonCoords = [
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
            CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
            CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
        ]
        var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)), isSelected: false, isDraggable: false)
        let customData: JSONObject = ["foo": .string("bar")]
        annotation.customData = customData

        let actualCustomData = try XCTUnwrap(annotation.feature.properties?["custom_data"])
        XCTAssertEqual(actualCustomData, .object(customData))
    }
}

// End of generated file
