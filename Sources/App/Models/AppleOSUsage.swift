//
//  AppleOSUsage.swift
//  
//
//  Created by Higashihara Yoki on 2021/11/28.
//

import Foundation

struct AppleOSUsage: Codable {
    var device: String
    var items: [Item]
    
    struct Item: Codable {
        var name: String
        var value: Int
    }
}
