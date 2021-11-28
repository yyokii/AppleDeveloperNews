//
//  iOSDevWeeklyIssue.swift
//  
//
//  Created by Higashihara Yoki on 2021/11/27.
//

import Fluent
import Vapor

public struct iOSDevWeeklyIssue {
    var title: String
    var pubDate: String
    var link: String
    var categories: [Category]
    
    struct Category {
        var title: String
        var items: [Item]
    }
    
    struct Item {
        var title: String
        var link: String
    }
}
