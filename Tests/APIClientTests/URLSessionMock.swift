import Foundation
@testable import APIClient

class URLSessionMock: URLSessionProtocol {
    func data(for request: URLRequest, delegate: (any URLSessionTaskDelegate)?) async throws -> (Data, URLResponse) {
        (try JSONEncoder().encode(Response(id: 1, text: "example")), URLResponse())
    }
}

class URLSessionErrorMock: URLSessionProtocol {
    func data(for request: URLRequest, delegate: (any URLSessionTaskDelegate)?) async throws -> (Data, URLResponse) {
        throw URLError(.unknown)
    }
}
