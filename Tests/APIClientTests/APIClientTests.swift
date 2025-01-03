import Testing
import Foundation
@testable import APIClient

struct APIClientTests {
    @Test
    func perform() async {
        let subject = APIClientProtocolImpl()
        
        
        let response = await subject.perform()
        
        
        #expect(response?.id == 1)
        #expect(response?.text == "example")
    }
    
    @Test
    func error() async {
        let subject = APIClientProtocolImpl(urlSession: URLSessionErrorMock())
        
        
        let response = await subject.perform()
        
        
        #expect(response == nil)
    }
    
    @Test
    func error_invalid_url() async {
        let subject = APIClientProtocolImpl(urlString: "127.0.0.1:8000/test")
        
        
        let response = await subject.perform()
        
        
        #expect(response == nil)
    }
}

struct Response: Codable {
    let id: Int
    let text: String
}

struct APIClientProtocolImpl: APIClientProtocol {
    typealias T = Response
    
    let urlString: String
    let path: String?
    let params: [String: String]?
    let httpMethod: APIClient.HTTPMethod
    let httpHeaders: [String : String]?
    let urlSession: any APIClient.URLSessionProtocol
    
    init(
        urlString: String = "https://hoge.com",
        path: String? = "/fuga",
        params: [String : String]? = ["key" : "value"],
        httpMethod: APIClient.HTTPMethod = .get,
        httpHeaders: [String : String]? = ["Authorization": "Bearer token"],
        urlSession: any APIClient.URLSessionProtocol = URLSessionMock()
    ) {
        self.urlString = urlString
        self.path = path
        self.params = params
        self.httpMethod = httpMethod
        self.httpHeaders = httpHeaders
        self.urlSession = urlSession
    }
}
