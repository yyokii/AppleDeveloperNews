//
//  GenerateAppleDevNews.swift
//  
//
//  Created by Higashihara Yoki on 2021/11/29.
//

import Fluent
import Queues
import Vapor

import MarkdownGenerator

struct RepsContentsUpdate: Encodable {
    var message: String
    var content: String
    var sha: String
    var branch: String
}

struct GenerateAppleDevNewsJob: AsyncScheduledJob {
    init() {}
    
    func run(context: QueueContext) async throws {
        let content = try await generateMdContent()
        try await updateGitHub(content: content.content)
    }
    
    func generateMdContent() async throws -> MarkdownContent {
        // Get data
        let topContent = MarkdownContentNormal(content: defaultReadMeContent)
        async let appleDevNews = getAppleDevNews()
        async let swiftLeeArticle = getSwiftLeeArticle()
        let datas = try await (appleDevNews: appleDevNews, swiftLeeArticle: swiftLeeArticle)
        let appleOSUsage = try getAppleOSUsage()
        let iOSDevWeeklyIssue = try getiOSDevWeeklyIssue()
        let iOSGoodiesPost = try getiOSGoodiesPost()
        
        // Create markdown content
        let content = topContent +
        datas.appleDevNews +
        appleOSUsage +
        iOSDevWeeklyIssue +
        iOSGoodiesPost +
        datas.swiftLeeArticle
        
        return content
    }
    
    func updateGitHub(content: String) async throws {
        let repositoryBranch: String = "main"
        let client = APIClient(host: APIClientHost.gitHub.rawValue)
        
        // Get repository info
        let repoData: RepositoryContents = try await client.send(.get("/repos/yyokii/AppleDeveloperNews/contents/README.md", query: ["ref": repositoryBranch] ))
        
        // Update contents
        let updateData = RepsContentsUpdate(message: "Update README with API",
                                            content: content.base64EncodedString,
                                            sha: repoData.sha,
                                            branch: repositoryBranch)
        
        let _: Void = try await client.send(.put("/repos/yyokii/AppleDeveloperNews/contents/README.md", body: updateData))
    }
    
    private func getAppleDevNews() async throws -> MarkdownContent {
        let client = APIClient(host: APIClientHost.rss2Json.rawValue)
        let data: AppleDeveloperNews = try await client.send(.get("/v1/api.json?rss_url=https://developer.apple.com/news/rss/news.rss"))
        
        // Create markdown
        let mdH2 = MarkdownHeader(level: .h2, header: data.feed.title)
        
        let latestNews = data.items[0]
        let mdNews = MarkdownLink(title: latestNews.title, link: latestNews.link)
        
        return mdH2 + mdNews
    }
    
    private func getAppleOSUsage() throws -> MarkdownContent {
        let urlString = "https://developer.apple.com/support/app-store/"
        let url = URL(string: urlString)!
        let osUsage = try scrapeiOSandiPadOSUsage(url: url)
        
        // Create markdown
        var content: MarkdownContent!
        let mdH2 = MarkdownHeader(level: .h2, header: "Apple OS Usage")
        let description = MarkdownLink(title: "data from here", link: urlString)
        content = mdH2 + description
        for usage in osUsage {
            let mdH3 = MarkdownHeader(level: .h3, header: usage.device)
            let lists: [String] = usage.items
                .map {
                    "\($0.name): \($0.value)%"
                }
            let usageList = MarkdownUnorderedLists(contents: lists)
            content = content + mdH3 + usageList
        }
        return content
    }
    
    private func getiOSDevWeeklyIssue() throws -> MarkdownContent {
        let urlString = "https://iosdevweekly.com/"
        let url = URL(string: urlString)!
        let data = try scrapeiOSDevWeekly(url: url)
        
        // Create markdown
        var content: MarkdownContent!
        let mdH2 = MarkdownHeader(level: .h2, header: "iOS Dev Weekly")
        let description = MarkdownLink(title: data.title, link: data.link)
        content = mdH2 + description
        for category in data.categories {
            let mdH3 = MarkdownHeader(level: .h3, header: category.title)
            let lists: [String] = category.items
                .map {
                    MarkdownLink(title: $0.title, link: $0.link).content
                }
            let linkList = MarkdownUnorderedLists(contents: lists)
            content = content + mdH3 + linkList
        }
        return content
    }
    
    private func getiOSGoodiesPost() throws -> MarkdownContent {
        let urlString = "https://ios-goodies.com/"
        let url = URL(string: urlString)!
        let data = try scrapeiOSGoodies(url: url)
        
        // Create markdown
        var content: MarkdownContent!
        let mdH2 = MarkdownHeader(level: .h2, header: "iOS Goodies")
        let description = MarkdownLink(title: data.title, link: data.link)
        content = mdH2 + description
        for topic in data.topics {            
            let mdH3 = MarkdownHeader(level: .h3, header: topic.title)
            let lists: [String] = topic.items
                .map {
                    MarkdownLink(title: $0.title, link: $0.link).content
                }
            let linkList = MarkdownUnorderedLists(contents: lists)
            content = content + mdH3 + linkList
        }
        return content
    }
    
    private func getSwiftLeeArticle() async throws -> MarkdownContent {
        let client = APIClient(host: APIClientHost.rss2Json.rawValue)
        let data: SwiftLeeArticles = try await client.send(.get("/v1/api.json?rss_url=https://www.avanderlee.com/feed"))
        
        // Create markdown
        let mdH2 = MarkdownHeader(level: .h2, header: data.feed.title)
        
        let latestNews = data.items[0]
        let mdArticle = MarkdownLink(title: latestNews.title, link: latestNews.link)
        
        return mdH2 + mdArticle
    }
}
