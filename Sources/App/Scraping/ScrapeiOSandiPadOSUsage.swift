//
//  ScrapeiOSandiPadOSUsage.swift
//  
//
//  Created by Higashihara Yoki on 2021/11/28.
//

import Foundation
import SwiftSoup

func scrapeiOSandiPadOSUsage(url: URL) throws -> [AppleOSUsage] {
    let html = try String(contentsOf: url)
    let document = try SwiftSoup.parse(html)
    
    guard let osChartsDivElement = try? document.select("div.os-charts").first() else {
        throw ScrapingError.failedSearch
    }
    
    let iPhoneData = scrapeOSData(of: "iPhone", from: osChartsDivElement)
    let iPadData = scrapeOSData(of: "iPad", from: osChartsDivElement)
    
    return [iPhoneData, iPadData]
}

func scrapeOSData(of deviceName: String, from element: Element) -> AppleOSUsage {
    let h4Element = try? element.select("h4")
    let iPhoneTextElement = h4Element?.first(where: {
        guard let text = try? $0.text() else {
            return false
        }
        return text == deviceName
    })
    let iPhoneTextElementParent = iPhoneTextElement?.parent()
    let chartElement = try? iPhoneTextElementParent?.nextElementSibling()
    let chartData = try? chartElement?.select("div[data-bar-chart]").first()?.attr("data-bar-chart")
    
    var usageData = AppleOSUsage(device: deviceName,
                                    items: [])
    
    if let chartData = chartData {
        let data = chartData.data(using: .utf8)!
        let items = try! JSONDecoder().decode([AppleOSUsage.Item].self, from: data)
        usageData.items = items
    }
    
    return usageData
}
