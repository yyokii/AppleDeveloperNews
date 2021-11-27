//
//  SwiftLeeArticle.swift
//  
//
//  Created by Higashihara Yoki on 2021/11/27.
//

import Fluent
import Vapor

public struct SwiftLeeArticles: Codable {
    let items: [SwiftLeeArticle]
    public let feed: SwiftLeeArticleFeed
}

public struct SwiftLeeArticleFeed: Codable {
    let url: String
    let title: String
    let link: String
    let author: String
    let description: String
    let image: String
}

final class SwiftLeeArticle: Model, Content {
    static let schema = "swiftLeeArticle"
    
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


