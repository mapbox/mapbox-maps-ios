import Foundation
import XCTest

func assertFirstCallParameterEqual<P, R>(
    _ methodStub: Stub<P, R>,
    _ firstParameter: P,
    _ message: String = "",
    file: StaticString = #file,
    line: UInt = #line) where P: Equatable {
        XCTAssertFalse(methodStub.parameters.isEmpty, message, file: file, line: line)
        XCTAssertEqual(methodStub.parameters.first, firstParameter, message, file: file, line: line)
    }

func assertLastCallParameterEqual<P, R>(
    _ methodStub: Stub<P, R>,
    _ firstParameter: P,
    _ message: String = "",
    file: StaticString = #file,
    line: UInt = #line) where P: Equatable {
        XCTAssertFalse(methodStub.parameters.isEmpty, message, file: file, line: line)
        XCTAssertEqual(methodStub.parameters.last, firstParameter, message, file: file, line: line)
    }

func assertCallParametersEqual<P, R>(
    _ methodStub: Stub<P, R>,
    _ parameters: P...,
    message: String = "",
    file: StaticString = #file,
    line: UInt = #line) where P: Equatable {
        XCTAssertEqual(methodStub.parameters, parameters, message, file: file, line: line)
    }

func assertFirstCallParameterIdentical<P, R>(
    _ methodStub: Stub<P, R>,
    _ firstParameter: P,
    _ message: String = "",
    file: StaticString = #file,
    line: UInt = #line) where P: AnyObject {
        XCTAssertFalse(methodStub.parameters.isEmpty, message, file: file, line: line)
        XCTAssertIdentical(methodStub.parameters.first, firstParameter, message, file: file, line: line)
    }

func assertLastCallParameterIdentical<P, R>(
    _ methodStub: Stub<P, R>,
    _ firstParameter: P,
    _ message: String = "",
    file: StaticString = #file,
    line: UInt = #line) where P: AnyObject {
        XCTAssertFalse(methodStub.parameters.isEmpty, message, file: file, line: line)
        XCTAssertIdentical(methodStub.parameters.last, firstParameter, message, file: file, line: line)
    }

func assertCallParametersIdentical<P, R>(
    _ methodStub: Stub<P, R>,
    _ parameters: P...,
    message: String = "",
    file: StaticString = #file,
    line: UInt = #line) where P: AnyObject {
        XCTAssertIdentical(methodStub.parameters as AnyObject, parameters, message, file: file, line: line)
    }

func assertMethodCall<P, R>(
    _ methodStub: Stub<P, R>,
    times: Int = 1,
    _ message: String = "",
    file: StaticString = #file,
    line: UInt = #line) {
        XCTAssertEqual(methodStub.invocations.count, times, message, file: file, line: line)
    }

func assertMethodNotCall<P, R>(
    _ methodStub: Stub<P, R>,
    _ message: String = "",
    file: StaticString = #file,
    line: UInt = #line) {
        XCTAssertTrue(methodStub.invocations.isEmpty, message, file: file, line: line)
    }
