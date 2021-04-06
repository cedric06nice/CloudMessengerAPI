import Fluent
import FluentSQLiteDriver
import FluentMySQLDriver
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    
    app.routes.defaultMaxBodySize = "10mb"
    
    if app.environment == .production {
        app.http.server.configuration.hostname = Secrets.Server.hostname
        app.http.server.configuration.port = Secrets.Server.port

        app.databases.use(.mysql(hostname: Secrets.MySQL.hostname,
                                username: Secrets.MySQL.username,
                                 password: Secrets.MySQL.password,
                                 database: Secrets.MySQL.database,
                                 tlsConfiguration: TLSConfiguration.forClient(certificateVerification: .none)), as: .mysql)
    } else {
        app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)
    }
    
    // configure migrations
    app.migrations.add(CreateUser())
    app.migrations.add(CreateUserToken())
    app.migrations.add(CreateMessage())
    app.migrations.add(DBUpdatePicture())

    // enable automatic migration
    try app.autoMigrate().wait()

    // register routes
    try routes(app)
}
