import XCTest
@testable import MapboxMaps

final class StyleEncodableTests: XCTestCase {
    private var testStruct: TestStruct!
    private let userInfoKey = CodingUserInfoKey(rawValue: "testCodingKey")!

    override func setUp() {
        super.setUp()
        testStruct = TestStruct()
    }

    override func tearDown() {
        testStruct = nil
        super.tearDown()
    }

    func testNoUserInfoKeys() {
        XCTAssertThrowsError(try testStruct.jsonObject()) { error in
            XCTAssertEqual(error as? Error, Error.customUserInfoMissing)
        }
    }

    func testUserInfoKeys() {
        let userInfoValue = String.randomAlphanumeric(withLength: 10)

        do {
            let jsonObject = try testStruct.jsonObject(userInfo: [userInfoKey: userInfoValue])
            // the JSON object should contain the passed user info key and value
            let customUserInfoKey = jsonObject[TestStruct.CodingKeys.customUserInfoKey.rawValue] as? String
            let customUserInfoValue = jsonObject[TestStruct.CodingKeys.customUserInfoValue.rawValue] as? String

            XCTAssertEqual(userInfoKey.rawValue, customUserInfoKey)
            XCTAssertEqual(userInfoValue, customUserInfoValue)
        } catch {
            switch error {
            case Error.customUserInfoMissing:
                XCTFail("StyleEncodable did pass the provided user info keys to its JSON decoder.")
            default:
                XCTFail("Encoding failed.")
            }
        }
    }
}

private enum Error: Swift.Error {
    case customUserInfoMissing
}

private struct TestStruct: StyleEncodable, Encodable {
    enum CodingKeys: String, CodingKey {
        case customUserInfoKey
        case customUserInfoValue
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        guard let (key, value) = encoder.userInfo.first, let stringValue = value as? String else {
            throw Error.customUserInfoMissing
        }

        // encode passed key/valu instead of actual values for testing purposes
        try container.encode(key.rawValue, forKey: .customUserInfoKey)
        try container.encode(stringValue, forKey: .customUserInfoValue)
    }
}
