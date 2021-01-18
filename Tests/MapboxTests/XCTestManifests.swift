import XCTest

 #if !os(macOS) && !os(iOS)
 public func allTests() -> [XCTestCaseEntry] {
     return [
         testCase(CMapboxTests.allTests)
     ]
 }
 #endif
