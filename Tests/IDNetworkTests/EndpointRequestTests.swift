import XCTest
@testable import IDNetwork

struct EndpointStub: Endpoint {
    var baseURL: String = "http://example.com"
    var path: String = ""
    var method: HTTPMethod = .get
    var parameters: [String : Any]? = nil
    var encoding: NetworkRequestParameterEncoding = .url
    var headers: [String : String]? = nil
}

final class EndpointRequestTests: XCTestCase {
    func testBrokenUrl() {
        let endpoint = EndpointStub(baseURL: "")
        XCTAssertNil(endpoint.request, "asd is not a proper url")
    }
    
    func testUrl() {
        let endpoint = EndpointStub()
        
        guard let request = endpoint.request else {
            XCTAssert(false, "Request should be valid")
            return
        }
        
        XCTAssertEqual(request.url, URL(string: endpoint.baseURL + endpoint.path), "Request url does not match")
    }
    
    func testHTTPMethod() {
        let method = HTTPMethod.post
        let endpoint = EndpointStub(method: method)
        
        guard let request = endpoint.request else {
            XCTAssert(false, "Request should be valid")
            return
        }
        
        XCTAssertEqual(request.httpMethod?.lowercased(), method.rawValue.lowercased(), "httpMethod mismatch")
    }
    
    
    // TODO: Test escaping and more types in the parameters dictionary (nested dictionary, array, etc)
    func testUrlEncoding() {
        let parameters: [String : Any] = [
            "foo" : 1,
            "bar" : "foobar",
            "isBar" : true
        ]
        let endpoint = EndpointStub(parameters: parameters,
                                    encoding: .url)
        
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
        let endpoint = EndpointStub(parameters: parameters,
                                    encoding: .json)
        
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
