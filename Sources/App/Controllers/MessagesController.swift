//
//  File.swift
//  
//
//  Created by cedric06nice on 07/03/2021.
//

import Fluent
import Vapor

struct MessagesController: RouteCollection {
    let websocketController = WebSocketController()
    let photoController = PhotoController()
    func boot(routes: RoutesBuilder) throws {
        let messagesRoute = routes.grouped("messages")
        
        let tokenProtected = messagesRoute.grouped(UserToken.authenticator(), UserToken.guardMiddleware())
        tokenProtected.post("new-message", use: newMessage)
        tokenProtected.post("report-message", use: reportMessage)
        tokenProtected.post("unflag-message", use: unflagMessage)
        tokenProtected.post("delete-message", use: deleteMessage)
        tokenProtected.get("all-messages", use: getAllMessages)
        
        let photoRoute = routes.grouped("photos")
        let tokenProtectedPhoto = photoRoute.grouped(UserToken.authenticator(), UserToken.guardMiddleware())
        tokenProtectedPhoto.post("upload-picture", use: uploadPicture)
        tokenProtectedPhoto.get("get-picture", use: photoController.getPicture)
        
        
        //création du Websocket protéger par token auth
        tokenProtected.webSocket("message-web-socket") { (req, ws) in
            websocketController.WebSocketsManagement(ws: ws, req: req)
        }
    }
    
    fileprivate func newMessage(req: Request) throws -> EventLoopFuture<Message> {
        try req.auth.require(User.self)
        let message = try req.content.decode(Message.self)
        return message.save(on: req.db).transform(to: message)
    }
    
    fileprivate func uploadPicture(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return try photoController.uploadPicture(req: req) { (channel) in
            websocketController.getAllMessagesAndSendForAll(req: req, channel: channel)
        }
    }
    
    fileprivate func getAllMessages(req: Request) throws -> EventLoopFuture<[Message]> {
        return Message.query(on: req.db)
            .sort(\.$timestamp, .descending)
            .all()
    }
    
    fileprivate func reportMessage(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let messageIdReceive = try req.content.decode(Message.PostingMessageId.self)
        return Message.find(messageIdReceive.id, on: req.db)
            .unwrap(or: Abort(.badRequest))
            .flatMap { (message) -> EventLoopFuture<HTTPStatus> in
                message.flag = true
                return message.update(on: req.db)
                    .map({ () in
                        websocketController.getAllMessagesAndSendForAll(req: req, channel: message.channel)
                    })
                    .transform(to: HTTPStatus.init(statusCode: 200))
            }
    }
    
    fileprivate func unflagMessage(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let user = try req.auth.require(User.self)
        guard user.isModerator == true
            else { throw Abort(.forbidden) }
        let messageIdReceive = try req.content.decode(Message.PostingMessageId.self)
        return Message.find(messageIdReceive.id, on: req.db)
            .unwrap(or: Abort(.badRequest))
            .flatMap { (message) -> EventLoopFuture<HTTPStatus> in
                message.flag = false
                return message.update(on: req.db)
                    .map({ () in
                        websocketController.getAllMessagesAndSendForAll(req: req, channel: message.channel)
                    })
                    .transform(to: HTTPStatus.init(statusCode: 200))
            }
    }
    
    fileprivate func deleteMessage(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let user = try req.auth.require(User.self)
        let messageIdReceive = try req.content.decode(Message.PostingMessageId.self)
        
        return Message.find(messageIdReceive.id, on: req.db)
            .unwrap(or: Abort(.badRequest))
            .flatMapThrowing { (message) -> HTTPStatus in
                guard user.isModerator == true || messageIdReceive.id == user.id
                            else { throw Abort(.forbidden) }
                 _ = message.delete(on: req.db)
                    .map({ () in
                        websocketController.getAllMessagesAndSendForAll(req: req, channel: message.channel)
                    })
                return HTTPStatus.init(statusCode: 200)
            }
    }
}

extension Message {
    struct PostingMessageId : Content {
        let id:UUID
    }
}
