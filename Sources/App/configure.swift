import Fluent
import FluentPostgresDriver
import Queues
import QueuesRedisDriver
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    try app.queues.use(.redis(url: Environment.get("REDIS_URL") ?? ""))

    let generateAppleDevNews = GenerateAppleDevNewsJob()
    app.queues.schedule(generateAppleDevNews).weekly().on(.sunday).at(.noon)
    
    try app.queues.startScheduledJobs()
    
    try routes(app)

}
