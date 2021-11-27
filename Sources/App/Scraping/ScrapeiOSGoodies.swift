//
//  File.swift
//  
//
//  Created by Higashihara Yoki on 2021/11/27.
//

import Foundation
import SwiftSoup

enum ScrapingError: Error {
    case failedSearch
    case noContent
}

func scrapeiOSGoodies(url: URL) throws -> iOSGoodiesArticle {
    let html = try String(contentsOf: url)
    let document = try SwiftSoup.parse(html)
    
    guard let post = try document.select("section.post").first() else {
        throw ScrapingError.failedSearch
    }
    
    var article = iOSGoodiesArticle()
    let postDataElements: Elements = post.children()
    
    for element in postDataElements {
        switch element.tagName() {
        case "section":
            guard let div = try element.select("div.post-date").first(),
                  let aTag = try div.select("a").first() else {
                      throw ScrapingError.failedSearch
                  }
            let dateText = try aTag.text()
            article.pubDate = dateText
        case "h2":
            guard let aTag = try element.select("a").first() else {
                      throw ScrapingError.failedSearch
                  }
            let title = try aTag.text()
            let link = try aTag.attr("href")
            
            article.title = title
            article.link = link
        default:
            break
        }
    }
    
    return article
}
