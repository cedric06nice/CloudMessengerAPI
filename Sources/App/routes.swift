import Fluent
import Vapor

func routes(_ app: Application) throws {
    
    try app.register(collection: UserController())
    try app.register(collection: MessagesController())
    try app.register(collection: PhotoController())
    try app.register(collection: ChannelController())
}
