//
//  ScrapeiOSDevWeekly.swift
//  
//
//  Created by Higashihara Yoki on 2021/11/27.
//

import Foundation
import SwiftSoup

func scrapeiOSDevWeekly(url: URL) throws -> iOSDevWeeklyIssue {
    let html = try String(contentsOf: url)
    let document = try SwiftSoup.parse(html)
    
    // Search issue data
    guard let issue = try document.select("header.issue__heading").first(),
          let issueTitleElement = try? issue.select("a").first(),
          let issueTitle = try? issueTitleElement.text(),
          let issueLink = try? issueTitleElement.attr("href"),
          let issuePubDate = try issue.select("time.published").first()?.text() else {
              throw ScrapingError.failedSearch
          }
    var issueData = iOSDevWeeklyIssue(title: issueTitle,
                                      pubDate: issuePubDate,
                                      link: "\(url.absoluteString)\(issueLink)",
                                      categories: [])
    
    // Search category and item datas
    guard let issueBody = try? document.select("div.issue__body").first() else {
        throw ScrapingError.failedSearch
    }
    
    for element in issueBody.children() {
        switch element.tagName() {
        case "section":
            if let classNames = try? element.classNames(),
               classNames.contains(where: { $0 == "cc-comment" || $0 == "cc-jobs" || $0 == "cc-finally"}) {
                // Skip comment, jobs, finally category
                continue
            }
            
            guard let categoryParent = try? element.select("div.i").first() else {
                continue
            }
            var category = iOSDevWeeklyIssue.Category(title: "",
                                                      items: [])
            for content in categoryParent.children() {
                switch content.tagName() {
                case "h2":
                    // Search category title
                    guard let title = try content.select("span.category__title__text").first()?.text() else {
                        continue
                    }
                    category.title = title
                case "div":
                    guard let h3Element = try? content.select("h3.item__title").first(),
                          let linkElement = try? h3Element.select("a").first(),
                          let title = try? linkElement.text(),
                          let link = try? linkElement.attr("href") else {
                              continue
                          }
                    
                    let itemData = iOSDevWeeklyIssue.Item(title: title, link: link)
                    category.items.append(itemData)
                default:
                    break
                }
            }
            issueData.categories.append(category)
        default:
            break
        }
    }
    
    //    print("---")
    //    print(issueData.title)
    //    print(issueData.link)
    //    for category in issueData.categories {
    //        print("---")
    //        print(category.title)
    //        for item in category.items {
    //            print(item.title)
    //        }
    //    }
    return issueData
}
