import XCTest

import IDNetworkTests

var tests = [XCTestCaseEntry]()
tests += EndpointRequestTests.allTests()
XCTMain(tests)
