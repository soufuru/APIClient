import Foundation
import os

enum HTTPMethod: String {
    case get
    case post
    case put
    case delete
}

protocol URLSessionProtocol {
    func data(for request: URLRequest, delegate: (any URLSessionTaskDelegate)?) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

protocol APIClientProtocol {
    associatedtype T: Codable
    
    var urlString: String { get }
    var httpMethod: HTTPMethod { get }
    var parameters: [String: String]? { get }
    var strategy: JSONDecoder.KeyDecodingStrategy { get }
    
    var urlSession: URLSessionProtocol { get }
    
    func perform() async -> T?
}

extension APIClientProtocol {
    var strategy: JSONDecoder.KeyDecodingStrategy { .convertFromSnakeCase }
    var urlSession: URLSessionProtocol { URLSession.shared }
    
    func perform() async -> T? {
        guard let url = URL(string: urlString) else { return nil }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = httpMethod.rawValue
        parameters?.forEach { key, value in
            urlRequest.addValue(key, forHTTPHeaderField: value)
        }
        
        do {
            let (data, _) = try await urlSession.data(for: urlRequest, delegate: nil)
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = strategy
            
            return try decoder.decode(T.self, from: data)
        } catch {
            Logger().error("JSONDecoder error: \(error)")
            return nil
        }
    }
}
