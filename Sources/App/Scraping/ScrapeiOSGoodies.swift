//
//  ScrapeiOSGoodies.swift
//  
//
//  Created by Higashihara Yoki on 2021/11/27.
//

import Foundation
import SwiftSoup

func scrapeiOSGoodies(url: URL) throws -> iOSGoodiesPost {
    let html = try String(contentsOf: url)
    let document = try SwiftSoup.parse(html)
    
    guard let post = try document.select("section.post").first() else {
        throw ScrapingError.failedSearch
    }
    
    var postData = iOSGoodiesPost.makeEmptyData()
    let postDataElements: Elements = post.children()
    
    for element in postDataElements {
        switch element.tagName() {
        case "section":
            guard let div = try element.select("div.post-date").first(),
                  let aTag = try div.select("a").first() else {
                      throw ScrapingError.failedSearch
                  }
            let dateText = try aTag.text()
            postData.pubDate = dateText
        case "h2":
            guard let aTag = try element.select("a").first() else {
                throw ScrapingError.failedSearch
            }
            let title = try aTag.text()
            let link = try aTag.attr("href")
            
            postData.title = title
            postData.link = link
            
        case "div":
            for child in element.children() {
                if child.tagName() == "ul" {
                    guard let previous = try? child.previousElementSibling(),
                          let strongTag = try? previous.select("strong").first(),
                          let topicTitle = try? strongTag.text(),
                          topicTitle != "Contributors" else {
                              continue
                          }
                    
                    var topic = iOSGoodiesPost.Topic(title: topicTitle, items: [])
                    
                    for list in child.children() {
                        // li tag
                        guard let aTag = try? list.select("a").first(),
                              let title = try? aTag.text(),
                              let link = try? aTag.attr("href") else {
                                  continue
                              }
                        
                        let item = iOSGoodiesPost.Item(title: title,
                                                       link: link)
                        topic.items.append(item)
                    }
                    
                    postData.topics.append(topic)
                }
            }
        default:
            break
        }
    }
    
//    print("---")
//    print(postData.title)
//    for topic in postData.topics {
//        print("---")
//        print(topic.title)
//        for item in topic.items {
//            print(item.title)
//        }
//    }
    
    return postData
}
