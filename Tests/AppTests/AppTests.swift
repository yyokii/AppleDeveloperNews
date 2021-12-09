@testable import App
import XCTVapor

import MarkdownGenerator

final class AppTests: XCTestCase {
    
    func testGenerateDemoMarkdown() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)
        
        let job = GenerateAppleDevNewsJob()
        let content = try await job.generateMdContent()
        let currentDirectoryPath = FileManager().currentDirectoryPath
        let mdGenerator = MarkdownFileGenerator(basePath: "\(currentDirectoryPath)/Demo",
                                                filename: "demo",
                                                content: content)
        try mdGenerator.write()
    }
    
    func testGenerateDefaultContentMarkdown() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)
        
        let content = MarkdownContentNormal(content: defaultReadMeContent) + MarkdownContentNormal(content: "This is Demo")
        let currentDirectoryPath = FileManager().currentDirectoryPath
        let mdGenerator = MarkdownFileGenerator(basePath: "\(currentDirectoryPath)/Demo",
                                                filename: "demoDefaultContent",
                                                content: content)
        try mdGenerator.write()
    }
    
    func testHelloWorld() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        try app.test(.GET, "hello", afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "Hello, world!")
        })
    }
}
