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
    
    func testUrl() {
        let base = "example.com"
        let path = "/foo"
        let endpoint = EndpointStub(baseURL: base,
                                    path: path,
                                    method: .get,
                                    parameters: nil,
                                    encoding: .json,
                                    headers: nil)
        
        guard let request = endpoint.request else {
            XCTAssert(false, "Request should be valid")
            return
        }
        
        XCTAssertEqual(request.url, URL(string: base + path), "Request url does not match")
    }
    
    func testHTTPMethod() {
        let method = HTTPMethod.get
        let endpoint = EndpointStub(baseURL: "example.com",
                                    path: "",
                                    method: method,
                                    parameters: [
                                        "foo" : 1,
                                        "bar" : "foobar",
                                        "isBar" : true],
                                    encoding: .url,
                                    headers: nil)
        
        guard let request = endpoint.request else {
            XCTAssert(false, "Request should be valid")
            return
        }
        
        XCTAssertEqual(request.httpMethod?.lowercased(), method.rawValue.lowercased(), "httpMethod mismatch")
    }
    
    
    // TODO: Test escaping and more types in the parameters dictionary (nested dictionary, array, etc)
    func testUrlEncoding() {
        let endpoint = EndpointStub(baseURL: "example.com",
        path: "",
        method: .get,
        parameters: [
            "foo" : 1,
            "bar" : "foobar",
            "isBar" : true],
        encoding: .url,
        headers: nil)
        
        XCTAssertNotNil(endpoint.request, "Request should be valid")
        guard let url = endpoint.request?.url else {
            XCTAssert(false, "Endpoint Request must produce an URL")
            return
        }
        
        let urlComponents = URLComponents(url: url , resolvingAgainstBaseURL: true)
        let pairs = urlComponents!.queryItems!.map { ($0.name, $0.value) }
        
        XCTAssertNotNil(urlComponents, "Endpoint Request must produce components")
        XCTAssertNotNil(urlComponents!.queryItems!, "Components must produce queryItems")
        XCTAssertEqual(urlComponents!.queryItems!.count, 3, "Three query components")
        
        XCTAssertTrue(pairs.contains(where: { $0 == ("foo", "1") }), "Must contain foo=1")
        XCTAssertTrue(pairs.contains(where: { $0 == ("bar", "foobar") }), "Must contain foo=1")
        XCTAssertTrue(pairs.contains(where: { $0 == ("isBar", "1") }), "Must contain foo=1")
    }
    
    func testJsonEncoding() {
        let parameters: [String : Any] = [
            "foo" : 1,
            "bar" : "foobar",
            "isBar" : true
        ]
        
        let endpoint = EndpointStub(baseURL: "example.com",
        path: "",
        method: .get,
        parameters: parameters,
        encoding: .json,
        headers: nil)
        
        guard let request = endpoint.request else {
            XCTAssert(false, "Request should be valid")
            return
        }
        
        
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json", "Content-Type must be json for json encoding requests")
        XCTAssertNotNil(request.httpBody, "Request should have body data")
        
        guard let data = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            XCTAssert(false, "Parameters should serialize to JSON")
            return
        }
        
        XCTAssertEqual(request.httpBody, data, "Serialized parameters do not match")
    }
    
    func testHeaders() {
        let headers: [String : String] = [
            "Accept-Encoding" : "gzip,deflate",
            "Accept" : "application/json",
            "Cache-Control" : "no-cache"
        ]
        
        let endpoint = EndpointStub(baseURL: "example.com",
        path: "",
        method: .get,
        parameters: nil,
        encoding: .json,
        headers: headers)
        
        guard let request = endpoint.request else {
            XCTAssert(false, "Request should be valid")
            return
        }
        
        for (title, value) in headers {
            XCTAssertEqual(request.value(forHTTPHeaderField: title), value, "Request header value mismatch for \(title)")
        }
    }

    static var allTests = [
        ("testBrokenUrl", testBrokenUrl),
        ("testUrl", testUrl),
        ("testHTTPMethod", testHTTPMethod),
        ("testUrlEncoding", testUrlEncoding),
        ("testJsonEncoding", testJsonEncoding),
        ("testHeaders", testHeaders)
    ]
}
