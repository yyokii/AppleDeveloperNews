//
//  APIClientError.swift
//  
//
//  Created by Higashihara Yoki on 2021/11/01.
//

import Foundation

enum APIClientError: Error {
    case connectionError(Data)
    case apiError
}
