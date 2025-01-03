import Foundation
import os

public enum HTTPMethod: String {
    case get
    case post
    case put
    case delete
}

public protocol URLSessionProtocol {
    func data(for request: URLRequest, delegate: (any URLSessionTaskDelegate)?) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

public protocol APIClientProtocol {
    associatedtype T: Codable
    
    var urlString: String { get }
    var path: String? { get }
    var params: [String: String] { get }
    var httpMethod: HTTPMethod { get }
    var httpHeaders: [String: String]? { get }
    var strategy: JSONDecoder.KeyDecodingStrategy { get }
    
    var urlSession: URLSessionProtocol { get }
    
    func perform() async -> T?
}

public extension APIClientProtocol {
    var strategy: JSONDecoder.KeyDecodingStrategy { .convertFromSnakeCase }
    var urlSession: URLSessionProtocol { URLSession.shared }
    var path: String? { nil }
    var params: [String: String] { [:] }
    
    func perform() async -> T? {
        let param = params.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        guard let url = URL(string: urlString + (path ?? "") + param) else {
            Logger().error("Invalid URL: \(urlString), \(path ?? ""), \(param)")
            return nil
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = httpMethod.rawValue
        httpHeaders?.forEach { key, value in
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
