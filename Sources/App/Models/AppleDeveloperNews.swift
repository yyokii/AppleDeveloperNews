//
//  AppleDeveloperNews.swift
//  
//
//  Created by Higashihara Yoki on 2021/11/26.
//

import Fluent
import Vapor

#warning("fix access level")
public struct AppleDeveloperNews: Codable {
    let items: [AppleDevNewsItem]
    public let feed: AppleDevNewsFeed
}

public struct AppleDevNewsFeed: Codable {
    let url: String
    let title: String
    let link: String
    let author: String
    let description: String
    let image: String
}

struct AppleDevNewsItem: Codable {
    let title: String
    let pubDate: String
    let link: String
    let guid: String
    let author: String
    let thumbnail: String
}

