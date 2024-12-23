import Testing
import Foundation
@testable import APIClient

struct APIClientTests {
    @Test
    func perform() async {
        let subject = APIClientProtocolImpl(
            urlString: "https://hoge.com",
            httpMethod: .get,
            parameters: ["Authorization": "Bearer token"],
            urlSession: URLSessionMock()
        )
        
        
        let response = await subject.perform()
        
        
        #expect(response?.id == 1)
        #expect(response?.text == "example")
    }
    
    @Test
    func error() async {
        let subject = APIClientProtocolImpl(
            urlString: "https://hoge.com",
            httpMethod: .get,
            parameters: ["Authorization": "Bearer token"],
            urlSession: URLSessionErrorMock()
        )
        
        
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
    let httpMethod: APIClient.HTTPMethod
    let parameters: [String : String]?
    let urlSession: any APIClient.URLSessionProtocol
}

