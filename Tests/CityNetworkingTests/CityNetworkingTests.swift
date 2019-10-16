import XCTest
@testable import CityNetworking

struct EndpointStub: Endpoint {
    let baseURL: String
    let path: String
    let method: HTTPMethod
    let parameters: [String : Any]?
    let encoding: NetworkRequestParameterEncoding
    let headers: [String : String]?
}

final class CityNetworkingTests: XCTestCase {
    func testBrokenUrl() {
        let endpoint = EndpointStub(baseURL: "",
                                    path: "",
                                    method: .get,
                                    parameters: nil,
                                    encoding: .json,
                                    headers: nil)
        XCTAssertNil(endpoint.request, "asd is not a proper url")
    }
    
    func testUrlEncoding() {
        let endpoint = EndpointStub(baseURL: "asd",
        path: "",
        method: .get,
        parameters: ["a" : 1, "b" : "2"],
        encoding: .url,
        headers: nil)
        
        XCTAssertNotNil(endpoint.request, "Request should be valid")
        guard let url = endpoint.request?.url else {
            XCTAssert(false, "Endpoint Request must produce an URL")
            return
        }
        let urlComponents = URLComponents(url: url , resolvingAgainstBaseURL: true)
        
        XCTAssertNotNil(urlComponents, "Endpoint Request must produce components")
        XCTAssertNotNil(urlComponents!.queryItems!, "Components must produce queryItems")
        XCTAssertEqual(urlComponents?.query, "a=1&b=2", "Wrong query string")
        XCTAssertEqual(urlComponents!.queryItems!.count, 2, "Two query components")
        
        XCTAssertEqual(urlComponents!.queryItems![0].name, "a", "Wrong parameter name")
        XCTAssertEqual(urlComponents!.queryItems![0].value, "1", "Wrong parameter value")
        XCTAssertEqual(urlComponents!.queryItems![1].name, "b", "Wrong parameter name")
        XCTAssertEqual(urlComponents!.queryItems![1].value, "2", "Wrong parameter value")
    }

    static var allTests = [
        ("testBrokenUrl", testBrokenUrl),
        ("testUrlEncoding", testUrlEncoding)
    ]
}
