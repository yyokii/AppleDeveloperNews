//
//  AppleDeveloperNews.swift
//  
//
//  Created by Higashihara Yoki on 2021/11/26.
//

import Fluent
import Vapor

public struct AppleDeveloperNews: Codable {
    let items: [AppleDevNewsItem]
}

final class AppleDevNewsItem: Model, Content {
    static let schema = "appleDeveloperNews"
    
    @ID
    var id: UUID?
    
    @Field(key: "title")
    var title: String
    
    @Field(key: "pubDate")
    var pubDate: String
    
    @Field(key: "link")
    var link: String
    
    @Field(key: "guid")
    var guid: String
    
    @Field(key: "author")
    var author: String
    
    @Field(key: "thumbnail")
    var thumbnail: String
    
    init() {}
    
    init(id: UUID? = nil,
         titel: String,
         pubDate: String,
         link: String,
         guid: String,
         author: String,
         thumbnail: String) {
        self.id = id
        self.title = title
        self.pubDate = pubDate
        self.link = link
        self.guid = guid
        self.author = author
        self.thumbnail = thumbnail
    }
}

