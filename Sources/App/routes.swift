import Fluent
import Vapor
import FCM

func routes(_ app: Application) throws {
    
    try app.register(collection: UserController())
    try app.register(collection: MessagesController())
    try app.register(collection: ChannelController())
}
