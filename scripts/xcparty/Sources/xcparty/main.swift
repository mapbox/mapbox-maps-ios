import Foundation
import XCResultKit

// Convenience struct
struct TestFailure: Hashable {
    var testCase: String
    var message: String
    var fileName: String?
    var startingLineNumber: String?

    init(testCase: String, message: String) {
        self.testCase = testCase
        self.message = message
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(testCase)
        hasher.combine(message)
        if let fileName = fileName {
            hasher.combine(fileName)
        }
        if let startingLineNumber = startingLineNumber {
            hasher.combine(startingLineNumber)
        }
    }
}

guard CommandLine.arguments.count >= 2 else {
    print("Usage: xcparty <path/to/xcresult> ... ")
    exit(1)
}

var failureDict = [String : Set<TestFailure>]()

let currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)

for xcresultFile in CommandLine.arguments[1...] {

    let xcresultPath = URL(fileURLWithPath: xcresultFile, relativeTo: currentDirectoryURL)

    // Parse using XCResultKit
    let resultFile = XCResultFile(url: xcresultPath)
    let invocationRecord = resultFile.getInvocationRecord()

    guard let failures = invocationRecord?.issues.testFailureSummaries else {
        continue
    }

    for failure in failures {
        let testCaseNameArray = failure.testCaseName.components(separatedBy: ".")

        guard testCaseNameArray.count == 2 else {
            continue
        }

        var testFailure = TestFailure(testCase: testCaseNameArray[1],
                                      message: failure.message)

        // Look for file name and line
        if let file = failure.documentLocationInCreatingWorkspace?.url,
           let url = URL(string: file) {
            testFailure.fileName = url.lastPathComponent

            if let fragment = url.fragment {
                let params = fragment.components(separatedBy: "&").map {
                    $0.components(separatedBy: "=")
                }

                let dict = params.reduce(into: [String:String]()) { (dict, keyValues) in
                    if keyValues.count == 2 {
                        dict[keyValues[0]] = keyValues[1]
                    }
                }

                testFailure.startingLineNumber = dict["StartingLineNumber"]
            }
        }

        // Group failures together
        failureDict[testCaseNameArray[0], default: []].update(with: testFailure)
    }
}

// Dump
if failureDict.count == 0 {
    print("No test failures detected.")
} else {
    for (key, value) in failureDict {
        let line = String(repeating: "-", count: key.count)
        print("\(key)\n\(line)")
        for test in value {
            print("• \(test.testCase)")

            if let fileName = test.fileName,
               let lineNumber = test.startingLineNumber {
                print("\t\(fileName) # \(lineNumber)")
            }
            print("\t\"\(test.message)\"")
        }
        print("")
    }
}



//    print("\t\(failure.testCaseName)\n\t\t\(failure.message)")
//    if let file = failure.documentLocationInCreatingWorkspace?.url {
//        let url = URL(fileURLWithPath: file)
//        if let file2 = url.pathComponents.last {
//            print("\t\t\(file2)<<<<")
//        }
//    }
//}


//    resultFile.getTestPlanRunSummaries(id: invocationRecord?.issues.errorSummaries)

//    guard let dict = NSDictionary(contentsOf: testSummaries) else {
//        print("can't parse")
//        exit(1)
//    }
//
//    guard let testableSummaries = dict["TestableSummaries"] as? [[String:Any]],
//          testableSummaries.count == 1 else {
//        print("can't parse 2")
//        exit(1)
//    }
//
//    guard let tests = testableSummaries.first?["Tests"] as? [[String:Any]] else {
//        print("can't parse 2")
//        exit(1)
//    }
//
//    guard let test = tests.first, tests.count == 1 else {
//        print("can't find first")
//        exit(1)
//    }
//    let indent = ""
//    recurse(indent, tests: test)



//}
//else {
//    print("v2")
//    let resultFile = XCResultFile(url: fullpath)
//    let invocationRecord = resultFile.getInvocationRecord()
//    print("\(invocationRecord)")
//}


func recurse(_ indent: String, tests: [String:Any]) {

    if let result = tests["TestStatus"] as? String,
       let name = tests["TestName"] as? String {
        print("\(indent)\(name) .... \(result)")
    }

    if let subtests = tests["Subtests"] as? [[String:Any]],
       let name = tests["TestName"] as? String {

        print("\(indent)\(name):")
        for subtest in subtests {
            recurse(indent+"\t", tests: subtest)
        }
    }
}

