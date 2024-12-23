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
            let decodedExpression = try JSONDecoder().decode(Exp.self, from: data!)
            XCTAssertEqual(decodedExpression.operator, .format)
            XCTAssertEqual(decodedExpression.arguments.first, .option(.format(FormatOptions())))
        } catch {
            XCTFail("Could not decode empty json as format expression")
        }
    }

    func testExpressionDecodingWhenSecondArgumentCouldBeAnOperator() {
        let jsonString = #"["array","number"]"#
        let data = jsonString.data(using: .utf8)!

        do {
            let actual = try JSONDecoder().decode(Exp.self, from: data)

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

        XCTAssertThrowsError(try JSONDecoder().decode(Exp.self, from: data))
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
        let expression = Exp(.distanceFromCenter) {
            Exp(.literal) { 1.0 }
        }

        XCTAssertEqual(expression.description, "[distance-from-center, [literal, 1.0]]")
    }

    func testPitchExpression() {
        let expression = Exp(.pitch) {
            Exp(.literal) { 20.0 }
        }

        XCTAssertEqual(expression.description, "[pitch, [literal, 20.0]]")
    }

    func testCreateOperatorlessExpression() {
        let expression = Exp {
            Exp(.sum) {
                Exp(.accumulated)
                Exp(.get) { "sum" }
            }
            Exp(.get) { "scalerank" }
        }

        XCTAssertEqual(expression.description, "[[+, [accumulated], [get, sum]], [get, scalerank]]")
    }

    func testCreateClusterPropertiesExpressions() {
        let maxExpression = Exp(.max) {Exp(.get) { "scalerank" }}
        let islandExpression = Exp(.any) {
            Exp(.eq) {
                Exp(.get) { "featureclass" }
                "island"
            }
        }
        let sumExpression = Exp {
            Exp(.sum) {
                Exp(.accumulated)
                Exp(.get) { "sum" }
            }
            Exp(.get) { "scalerank" }
        }

        XCTAssertEqual(maxExpression.description, "[max, [get, scalerank]]")
        XCTAssertEqual(islandExpression.description, "[any, [==, [get, featureclass], island]]")
        XCTAssertEqual(sumExpression.description, "[[+, [accumulated], [get, sum]], [get, scalerank]]")
    }

    func testDecodingForOperatorlessExpression() {

        let expressionString =
        """
        [
            ["+", ["accumulated"], ["get", "sum"]],
            ["get", "scalerank"]
        ]
        """
        let expressionData = expressionString.data(using: .utf8)
        XCTAssertNotNil(expressionData)

        do {
            let decodedExpression = try JSONDecoder().decode(Exp.self, from: expressionData!)
            let matchingExpression = Exp {
                Exp(.sum) {
                    Exp(.accumulated)
                    Exp(.get) { "sum" }
                }
                Exp(.get) { "scalerank" }
            }
            XCTAssertEqual(decodedExpression, matchingExpression)
            XCTAssertNoThrow(decodedExpression.operator)
            XCTAssertNoThrow(decodedExpression.arguments)
            XCTAssertEqual(decodedExpression.operator.rawValue, "+")
            XCTAssertEqual(decodedExpression.arguments.description, "[[+, [accumulated], [get, sum]], [get, scalerank]]")
        } catch {
            print(error)
            XCTFail("Could not decode json as expression")
        }
    }

    func testDecodingJSONToExpression() throws {

        let expressionString =
        """
        [
            "interpolate",
            ["linear"],
            ["zoom"],
            0,
            "hsl(0, 79%, 53%)",
            14,
            "hsl(233, 80%, 47%)"
        ]
        """
        let expressionData = expressionString.data(using: .utf8)
        XCTAssertNotNil(expressionData)

        do {
            let decodedExpression = try JSONDecoder().decode(Exp.self, from: expressionData!)
            let matchingExpression = Exp(.interpolate) {
                Exp(.linear)
                Exp(.zoom)
                0
                "hsl(0, 79%, 53%)"
                14
                "hsl(233, 80%, 47%)"
            }
            XCTAssertEqual(decodedExpression, matchingExpression)
        } catch {
            XCTFail("Could not decode json as expression")
        }
    }

    func testAccessExpressionOperatorForOperatorlessExpression() throws {
        let expectedExpressionOperator = Exp(.sum).operator
        let sumExpression = Exp {
            Exp(.sum) {
                Exp(.accumulated)
                Exp(.get) { "sum" }
            }
            Exp(.get) { "scalerank" }
        }

        let sumExpressionOperator = sumExpression.operator

        XCTAssertNoThrow(sumExpression.operator)
        XCTAssertEqual(expectedExpressionOperator, sumExpressionOperator)
    }

    func testAccessExpressionArgumentsForOperatorlessExpression() throws {
        let expectedExpressionArguments: [Exp.Argument] = [Exp.Argument.expression(Exp(.sum) {
            Exp(.accumulated)
            Exp(.get) { "sum" }
        }), Exp.Argument.expression(Exp(.get) { "scalerank" })]

        let sumExpression = Exp {
            Exp(.sum) {
                Exp(.accumulated)
                Exp(.get) { "sum" }
            }
            Exp(.get) { "scalerank" }
        }

        let sumExpressionArguments = sumExpression.arguments
        XCTAssertNoThrow(sumExpression.arguments)
        XCTAssertEqual(expectedExpressionArguments, sumExpressionArguments)
    }

    func testAccessExpressionDescriptionForOperatorlessExpression() throws {
        let expectedExpressionDescription = "[[+, [accumulated], [get, sum]], [get, scalerank]]"
        let sumExpression = Exp {
            Exp(.sum) {
                Exp(.accumulated)
                Exp(.get) { "sum" }
            }
            Exp(.get) { "scalerank" }
        }

        let sumExpressionDescription = sumExpression.description
        XCTAssertEqual(expectedExpressionDescription, sumExpressionDescription)
    }

    func testAccessExpressionOperatorForOperatorlessExpressionWithDepth() throws {
        let expectedExpressionOperator = Exp(.sum).operator
        let sumExpression = Exp {
            Exp {
                Exp(.sum) {
                    Exp(.accumulated)
                    Exp(.get) { "sum" }
                }
                Exp(.get) { "scalerank" }
            }
        }

        let sumExpressionOperator = sumExpression.operator
        XCTAssertNoThrow(sumExpression.operator)
        XCTAssertEqual(expectedExpressionOperator, sumExpressionOperator)
    }

    func testExpressionConstructorWithTrivialConvertibleArgument() throws {
        let shortFormExpression = Exp(.get, "name")
        let builderBasedExpression = Exp(.get) { "name" }

        XCTAssertEqual(shortFormExpression, builderBasedExpression)
    }

    func testExpressionConstructorWithComplexConvertibleArgument() throws {
        let shortFormExpression = Exp(.interpolate, Exp(.linear), Exp(.zoom), 15, 0, 15.05, 1)
        let longFormExpression = Exp(.interpolate) {
            Exp(.linear)
            Exp(.zoom)
            15
            0
            15.05
            1
        }

        XCTAssertEqual(shortFormExpression, longFormExpression)
    }

    func testExpressionConstructorWithComplexNotEqualConvertibleArgument() throws {
        let shortFormExpression = Exp(.interpolate, Exp(.linear, Exp(.zoom), 15, 0, 15.05, 1))
        let longFormExpression = Exp(.interpolate) {
            Exp(.linear)
            Exp(.zoom)
            15
            0
            15.05
            1
        }

        XCTAssertNotEqual(shortFormExpression, longFormExpression)
    }

    func testEncodeImageOptions() throws {
        let color = StyleColor(UIColor.black)
        let empty = ImageOptions([:])
        let constantValues = ImageOptions([
            "key": .constant(StyleColor("red")),
            "key2": .constant(color)

        ])
        let expression = Expression(.toRgba, Exp(.get, "color"))
        let expression2 = Exp(.switchCase) {
            Exp(.gte) {
                Exp(.toNumber) {
                    Exp(.get) { "point_count" }
                }
                4
            }
            "#ffffff"
            "#000000"
        }
        let expressionValues = ImageOptions([
            "key": .expression(expression),
            "key2": .expression(expression2)
        ])

        let emptyEncoded = try DictionaryEncoder().encode(empty)
        let constantValuesEncoded = try DictionaryEncoder().encode(constantValues)
        let expressionValuesParamsEncoded = try DictionaryEncoder().encode(expressionValues)["params"] as? [String: Any]

        XCTAssertEqual(emptyEncoded["params"] as? [String: String], [:])
        XCTAssertEqual(constantValuesEncoded["params"] as? [String: String], ["key": "red", "key2": color.rawValue])
        XCTAssertEqual(
            String(data: try JSONSerialization.data(withJSONObject: expressionValuesParamsEncoded?["key"] as Any), encoding: .utf8),
            ##"["to-rgba",["get","color"]]"##
        )
        XCTAssertEqual(
            String(data: try JSONSerialization.data(withJSONObject: expressionValuesParamsEncoded?["key2"] as Any), encoding: .utf8),
            ##"["case",[">=",["to-number",["get","point_count"]],4],"#ffffff","#000000"]"##
        )
    }

    func testDecodeImageOptions() throws {
        let jsonString = #"{"params": {"expression": ["get", "color"], "constant": "red", "rgb": "rgba(0, 0, 0, 1)"}}"#

        let imageOptions = try JSONDecoder().decode(ImageOptions.self, from: try XCTUnwrap(jsonString.data(using: .utf8)))

        XCTAssertEqual(imageOptions.options["expression"], Value.expression(Exp(.get) { "color" }))
        XCTAssertEqual(imageOptions.options["constant"], Value.constant(StyleColor(rawValue: "red")))
        XCTAssertEqual(imageOptions.options["rgb"], Value.constant(StyleColor("rgba(0, 0, 0, 1)")))
    }

    func testEncodeLiteralDictionary() throws {
        let expression = Exp(.literal) { ["opacity": 0.5] }

        let encoded = try JSONEncoder().encode(expression)

        XCTAssertEqual(
            String(data: encoded, encoding: .utf8),
            "[\"literal\",{\"opacity\":0.5}]"
            )
    }

    func testDecodeLiteralDictionary() {
        let expressionString =
            """
                ["literal",
                    {
                        "opacity":0.5,
                        "bkey":"bval",
                    }
                ]
            """

        let expression = try! XCTUnwrap(JSONDecoder().decode(Expression.self, from: expressionString.data(using: .utf8)!))

        XCTAssertEqual(expression, Exp(.literal) { ["opacity": 0.5, "bkey": "bval"] })
    }
}
