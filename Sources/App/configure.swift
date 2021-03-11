import Fluent
import FluentSQLiteDriver
import FluentMySQLDriver
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    if app.environment == .production {
        app.http.server.configuration.hostname = Secrets.Server.hostname
        app.http.server.configuration.port = Secrets.Server.port
        
        app.databases.use(.mysql(hostname: Secrets.MySQL.hostname,
                                 username: Secrets.MySQL.username,
                                 password: Secrets.MySQL.password,
                                 database: "vapor2",
                                 tlsConfiguration: TLSConfiguration.forClient(certificateVerification: .none)), as: .mysql)
    } else {
        app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)
    }
    
    // configure migrations
    app.migrations.add(CreateUser())
    app.migrations.add(CreateUserToken())
    app.migrations.add(CreateMessage())

    // enable automatic migration
    try app.autoMigrate().wait()

    // register routes
    try routes(app)
}
