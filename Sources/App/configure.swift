import Fluent
import FluentSQLiteDriver
import FluentMySQLDriver
import Vapor
import FCM

// configures your application
public func configure(_ app: Application) throws {
    
    //configuration of notifications
    app.fcm.configuration
        = FCMConfiguration(pathToServiceAccountKey: Secrets.Notication.PATH_TO_JSONKEY)
    
    app.fcm.configuration?.apnsDefaultConfig = FCMApnsConfig(headers: [:], aps: FCMApnsApsObject(
        badge: 1,
        sound: "default"
    ))
    app.fcm.configuration?.androidDefaultConfig = FCMAndroidConfig(
        ttl: "86400s",
        restricted_package_name: "net.skyisthelimit.pg_messenger",
        notification: FCMAndroidNotification(sound: "default"))
    
    
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
    app.migrations.add(CreateChannel())
    app.migrations.add(UpdateMessageForChannel())
    
    // enable automatic migration
    try app.autoMigrate().wait()
    
    // register routes
    try routes(app)
}
