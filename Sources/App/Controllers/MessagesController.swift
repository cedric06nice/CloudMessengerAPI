//
//  File.swift
//  
//
//  Created by cedric06nice on 07/03/2021.
//

import Fluent
import Vapor

struct MessagesController: RouteCollection {
    var websocketController = WebSocketController()
    func boot(routes: RoutesBuilder) throws {
        let messagesRoute = routes.grouped("messages")
        
        let tokenProtected = messagesRoute.grouped(UserToken.authenticator(), UserToken.guardMiddleware())
        tokenProtected.post("new-message", use: newMessage)
        tokenProtected.post("report-message", use: reportMessage)
        tokenProtected.get("all-messages", use: getAllMessages)
        
        
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
    
    fileprivate func getAllMessages(req: Request) throws -> EventLoopFuture<[Message]> {
        return Message.query(on: req.db)
            .sort(\.$timestamp, .descending)
            .all()
    }
    
    fileprivate func reportMessage(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        print("report")
        let messageIdReceive = try req.content.decode(Message.PostingMessageId.self)
        print(messageIdReceive)
        return Message.find(messageIdReceive.id, on: req.db)
            .unwrap(or: Abort(.badRequest))
            .flatMap { (message) -> EventLoopFuture<HTTPStatus> in
                message.flag = true
                return message.update(on: req.db)
                    .map({ () in
                        print("message updated")
                        websocketController.getAllMessagesAndSendForAll(req: req)
                    })
                    .transform(to: HTTPStatus.init(statusCode: 200))
            }
    }
}

extension Message {
    struct PostingMessageId : Content {
        let id:UUID
    }
}
