//
//  File.swift
//  
//
//  Created by Higashihara Yoki on 2021/11/27.
//

import Fluent
import Vapor


final class iOSGoodiesArticle: Model, Content {
    static let schema = "iOSGoodiesArticle"
    
    @ID
    var id: UUID?
    
    @Field(key: "title")
    var title: String
    
    @Field(key: "pubDate")
    var pubDate: String
    
    @Field(key: "link")
    var link: String
    
    init() {}
    
    init(id: UUID? = nil,
         titel: String,
         pubDate: String,
         link: String) {
        self.id = id
        self.title = title
        self.pubDate = pubDate
        self.link = link
    }
}
