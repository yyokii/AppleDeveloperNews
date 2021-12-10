//
//  APIClient.swift
//  
//
//  Created by Higashihara Yoki on 2021/11/27.
//

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

import Foundation

enum APIClientHost: String {
    case gitHub = "api.github.com"
    case rss2Json = "api.rss2json.com"
}

actor APIClient {
    private let session: URLSession
    private let host: String
    private let serializer = Serializer()
    private let delegate: APIClientDelegate
    
    init(host: String, configuration: URLSessionConfiguration = .default, delegate: APIClientDelegate? = nil) {
        self.host = host
        self.session = URLSession(configuration: configuration)
        self.delegate = delegate ?? DefaultAPIClientDelegate()
    }
    
    public func send<T: Decodable>(_ request: Request<T>) async throws -> T {
        try await send(request, serializer.decode)
    }
    
    public func send(_ request: Request<Void>) async throws -> Void {
        try await send(request) { _ in () }
    }
    
    private func send<T>(_ request: Request<T>, _ decode: @escaping (Data) async throws -> T) async throws -> T {
        let request = try await makeRequest(for: request)
        let (data, response) = try await send(request)
        try validate(response: response, data: data)
        return try await decode(data)
    }
    
    public func send(_ request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await actuallySend(request)
        } catch {
            guard await delegate.shouldClientRetry(self, withError: error) else { throw error }
            return try await actuallySend(request)
        }
    }
    
    private func actuallySend(_ request: URLRequest) async throws -> (Data, URLResponse) {
        var request = request
        
        if request.url?.host == APIClientHost.gitHub.rawValue {
            delegate.client(self, willSendRequest: &request)
        }
        return try await session.data(for: request, delegate: nil)
    }
    
    private func makeRequest<T>(for request: Request<T>) async throws -> URLRequest {
        let url = try makeURL(path: request.path, query: request.query)
        return try await makeRequest(url: url, method: request.method, body: request.body)
    }
    
    private func makeURL(path: String, query: [String: String]?) throws -> URL {
        guard let url = URL(string: path),
              var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                  throw URLError(.badURL)
              }
        if path.starts(with: "/") {
            components.scheme = "https"
            components.host = host
        }
        if let query = query {
            components.queryItems = query.map(URLQueryItem.init)
        }
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        return url
    }
    
    private func makeRequest(url: URL, method: String, body: AnyEncodable?) async throws -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        if let body = body {
            request.httpBody = try await serializer.encode(body)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }
    
    private func validate(response: URLResponse, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else { return }
        if !(200..<300).contains(httpResponse.statusCode) {
            print("❌ : code \(httpResponse.statusCode)")
            throw delegate.client(self, didReceiveInvalidResponse: httpResponse, data: data)
        }
    }
}

private actor Serializer {
    func encode<T: Encodable>(_ entity: T) async throws -> Data {
        try JSONEncoder().encode(entity)
    }
    
    func decode<T: Decodable>(_ data: Data) async throws -> T {
        try JSONDecoder().decode(T.self, from: data)
    }
}
