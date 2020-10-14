import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(JGProgressHUD_SwiftUITests.allTests),
    ]
}
#endif
