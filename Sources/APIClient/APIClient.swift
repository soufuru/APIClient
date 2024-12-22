import Foundation
import os

enum HTTPMethod: String {
    case get
    case post
    case put
    case delete
}

protocol APIClientProtocol {
    associatedtype T: Codable
    
    var urlString: String { get }
    var httpMethod: HTTPMethod { get }
    var parameters: [String: String]? { get }
    
    func perform() async -> T?
}

extension APIClientProtocol {
    
    
    func perform() async -> T? {
        guard let url = URL(string: urlString) else { return nil }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = httpMethod.rawValue
        parameters?.forEach { key, value in
            urlRequest.addValue(key, forHTTPHeaderField: value)
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            return try decoder.decode(T.self, from: data)
        } catch {
            Logger().error("JSONDecoder error: \(error)")
            return nil
        }
    }
}
