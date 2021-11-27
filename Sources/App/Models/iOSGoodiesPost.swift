//
//  File.swift
//  
//
//  Created by Higashihara Yoki on 2021/11/27.
//

import Fluent
import Vapor

public struct iOSGoodiesPost {
    var title: String
    var pubDate: String
    var link: String
    var topics: [Topic]
    
    struct Topic {
        var title: String
        var items: [Item]
    }
    
    struct Item {
        var title: String
        var link: String
    }
    
    static func makeEmptyData() -> Self {
        return iOSGoodiesPost(title: "",
                              pubDate: "",
                              link: "",
                              topics: [])
    }
}
