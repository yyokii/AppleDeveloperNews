//
//  SwiftLeeArticle.swift
//  
//
//  Created by Higashihara Yoki on 2021/11/27.
//

import Fluent
import Vapor

struct SwiftLeeArticles: Codable {
    let items: [SwiftLeeArticle]
    public let feed: SwiftLeeArticleFeed
}

struct SwiftLeeArticleFeed: Codable {
    let url: String
    let title: String
    let link: String
    let author: String
    let description: String
    let image: String
}

struct SwiftLeeArticle: Codable {
    let title: String
    let pubDate: String
    let link: String
    let guid: String
    let author: String
    let thumbnail: String
}


