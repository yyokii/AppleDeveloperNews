//
//  File.swift
//  
//
//  Created by Higashihara Yoki on 2021/12/05.
//

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

import Foundation
import Vapor

protocol APIClientDelegate {
    func client(_ client: APIClient, willSendRequest request: inout URLRequest)
    func shouldClientRetry(_ client: APIClient, withError error: Error) async -> Bool
    func client(_ client: APIClient, didReceiveInvalidResponse response: HTTPURLResponse, data: Data) -> Error
}

extension APIClientDelegate {
    func client(_ client: APIClient, willSendRequest request: inout URLRequest) {}
    func shouldClientRetry(_ client: APIClient, withError error: Error) async -> Bool { false }
    func client(_ client: APIClient, didReceiveInvalidResponse response: HTTPURLResponse, data: Data) -> Error {
        URLError(.cannotParseResponse, userInfo: [NSLocalizedDescriptionKey: "Response status code was unacceptable: \(response.statusCode)."])
    }
}

struct DefaultAPIClientDelegate: APIClientDelegate {
    func client(_ client: APIClient, willSendRequest request: inout URLRequest) {
        let token: String = Environment.get("GITHUB_TOKEN") ?? ""
        request.setValue("token \(token)", forHTTPHeaderField: "Authorization")
    }
}
