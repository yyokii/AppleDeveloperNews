//
//  Request.swift
//  
//
//  Created by Higashihara Yoki on 2021/11/27.
//

import Foundation

public struct Request<Response> {
    var method: String
    var path: String
    var query: [String: String]?
    var body: AnyEncodable?

    public static func get(_ path: String, query: [String: String]? = nil) -> Request {
        Request(method: "GET", path: path, query: query)
    }
    
    public static func post<U: Encodable>(_ path: String, body: U) -> Request {
        Request(method: "POST", path: path, body: AnyEncodable(body))
    }
    
    public static func patch<U: Encodable>(_ path: String, body: U) -> Request {
        Request(method: "PATCH", path: path, body: AnyEncodable(body))
    }
    
    public static func put<U: Encodable>(_ path: String, body: U) -> Request {
        Request(method: "PUT", path: path, body: AnyEncodable(body))
    }
    
    public static func delete<U: Encodable>(_ path: String, body: U) -> Request {
        Request(method: "DELETE", path: path, body: AnyEncodable(body))
    }
}

struct AnyEncodable: Encodable {
    private let value: Encodable

    init(_ value: Encodable) {
        self.value = value
    }

    func encode(to encoder: Encoder) throws {
        try value.encode(to: encoder)
    }
}
