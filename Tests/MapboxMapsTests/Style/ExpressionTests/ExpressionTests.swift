import XCTest
@testable import MapboxMaps
import CoreLocation

final class ExpressionTests: XCTestCase {

    func testExpressionValidity() {
        let sumExp = Exp(.sum) {
            10
            12
        }

        XCTAssertEqual(sumExp.operator, .sum)
        XCTAssertEqual(sumExp.arguments.count, 2)
        XCTAssertEqual(sumExp.arguments[0], .number(10))
        XCTAssertEqual(sumExp.arguments[1], .number(12))
    }
    //swiftlint:enable statement_position

    // Validates basic expression semantics
    func expressionValidator(exp: Exp) {
        XCTAssertNotNil(exp.operator)
        XCTAssertTrue(exp.arguments.count >= 1)
    }

    func testColorBasedExpression() throws {
        let expression = Exp(.interpolate) {
            Exp(.linear)
            Exp(.zoom)
            0
            UIColor.red
            14
            UIColor.blue
        }
        expressionValidator(exp: expression)
    }

    func testExpressionDecodingOnEmptyJSON() throws {

        let jsonString =
        """
        [ "format",
          {
          }
        ]
        """

        let data = jsonString.data(using: .utf8)
        XCTAssertNotNil(data)

        do {
            let decodedExpression = try JSONDecoder().decode(Expression.self, from: data!)
            XCTAssertEqual(decodedExpression.operator, .format)
            verifyExpressionArgument(for: decodedExpression,
                                     toMatch: .option(.format(FormatOptions())),
                                     at: 1)
        } catch {
            XCTFail("Could not decode empty json as format expression")
        }
    }

    func testExpressionDecodingWhenSecondArgumentCouldBeAnOperator() {
        let jsonString = #"["array","number"]"#
        let data = jsonString.data(using: .utf8)!

        do {
            let actual = try JSONDecoder().decode(Expression.self, from: data)

            XCTAssertEqual(actual, Exp(.array) {
                "number"
            })
        } catch {
            XCTFail("Decoding failed with error \(error)")
        }
    }

    func testExpressionDecodingFailsWhenOperatorIsMissing() {
        let jsonString = #"[]"#
        let data = jsonString.data(using: .utf8)!

        XCTAssertThrowsError(try JSONDecoder().decode(Expression.self, from: data))
    }

    // MARK: - Helpers
    func verifyExpressionArgument(for expression: Expression, toMatch argument: Expression.Argument, at index: Int) {

        guard let op = expression.elements.first, case .operator = op else {
            XCTFail("There was no valid operator in the first element of the expression array")
            return
        }

        let arg = expression.elements[index]
        guard case let .argument(validArg) = arg else {
            XCTFail("There was no valid argument in the element at index = \(index) of the expression array")
            return
        }
        print(validArg)

        XCTAssertEqual(validArg, argument)
    }

    func testGeoJSONObjectExpression() throws {
        let coloradoCorners: [CLLocationCoordinate2D] = [
            .init(latitude: 37, longitude: -109-2/60-48/60/60),
            .init(latitude: 37, longitude: -102-2/60-48/60/60),
            .init(latitude: 41, longitude: -102-2/60-48/60/60),
            .init(latitude: 41, longitude: -109-2/60-48/60/60),
            .init(latitude: 37, longitude: -109-2/60-48/60/60),
        ]
        var colorado = Feature(geometry: Polygon([coloradoCorners]))
        colorado.identifier = "CO"
        colorado.properties = [
            "population": 5_773_714,
        ]

        let withinExpression = Exp(.within) {
            GeoJSONObject.feature(colorado)
        }
        let firstArgument = try XCTUnwrap(withinExpression.arguments.first)
        XCTAssertEqual(firstArgument, .geoJSONObject(.feature(colorado)))

        let withinJSON = try XCTUnwrap(try withinExpression.toJSON() as? [Any?])
        XCTAssertEqual(withinJSON.first as? String, "within")
        XCTAssertEqual(withinJSON.count, 2)

        XCTAssertNotNil(withinJSON.last as? [String: Any?])
        guard let coloradoJSON = withinJSON.last as? [String: Any?] else { return }

        XCTAssertEqual(coloradoJSON.count, 4)
        XCTAssertEqual(coloradoJSON["type"] as? String, "Feature")
        XCTAssertEqual(coloradoJSON["id"] as? String, "CO")
        XCTAssertEqual(coloradoJSON["properties"] as? [String: Int],
                       ["population": 5_773_714])
    }

    func testDistanceFromCenterExpression() {
        let expression = Expression(.distanceFromCenter) {
            Expression(.literal) { 1.0 }
        }

        XCTAssertEqual(expression.description, "[distance-from-center, [literal, 1.0]]")
    }

    func testPitchExpression() {
        let expression = Expression(.pitch) {
            Expression(.literal) { 20.0 }
        }

        XCTAssertEqual(expression.description, "[pitch, [literal, 20.0]]")
    }

}
