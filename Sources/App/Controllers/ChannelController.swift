//
//  File.swift
//  
//
//  Created by Nicolas on 10/04/2021.
//

import Fluent
import Vapor
struct ChannelController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let messagesRoute = routes.grouped("channel")
        
        let tokenProtected = messagesRoute.grouped(UserToken.authenticator(), UserToken.guardMiddleware())
        tokenProtected.get("get-channel", use: getChannel)
        tokenProtected.post("create-channel", use: createChannel)
        
    }
    
    fileprivate func getChannel(req: Request) throws -> EventLoopFuture<[Channel]>{
        let user = try req.auth.require(User.self)
        if user.isModerator {
            return Channel.query(on: req.db).all()
        }else {
            return Channel.query(on: req.db).filter(\.$isPublic == true).all()
        }
    }
    
    fileprivate func createChannel(req:Request) throws -> HTTPStatus{
        let user = try req.auth.require(User.self)
        guard user.isModerator else {throw Abort(HTTPStatus.unauthorized)}
        let newChannel = try req.content.decode(Channel.CreateChannelByName.self)
        if let channelUsersID = newChannel.channelUsersID {
            _ = Channel.init(name: newChannel.name, channelUser: channelUsersID, isPublic: false).save(on: req.db)
            return HTTPResponseStatus.ok
        }
        if newChannel.isPublic {
            _ = Channel.query(on: req.db).all().flatMapThrowing { (channels) in
                if channels.contains(where: { (channel) -> Bool in
                    return (channel.name == newChannel.name)
                }){
                    throw Abort(HTTPStatus.conflict)
                }
            }.map({ () in
                User.query(on: req.db).all().map { (userArray) -> [UUID] in
                    return userArray.map { (user) -> UUID in
                        do {return try user.requireID()}catch{return UUID()}
                    }
                }.flatMap { (userID) in
                    Channel(name: newChannel.name,
                            channelUser: userID,
                            isPublic: true)
                        .save(on: req.db)
                        .transform(to: HTTPStatus.ok)
                }
            })
            
            return HTTPStatus.ok
        }else {
            _ = User.query(on: req.db)
                .filter(\.$isModerator == true)
                .all()
                .map({ (userArray) -> [UUID] in
                    return userArray.map { (user) -> UUID in
                        do {return try user.requireID()}catch{return UUID()}
                    }
                }).map({ (usersID) in
                    Channel(name: newChannel.name, channelUser: usersID, isPublic: false).save(on: req.db)
                })
            return HTTPStatus.ok
        }
    }
}

extension Channel {
    struct CreateChannelByName: Content {
        var name:String
        var isPublic:Bool
        var channelUsersID:[UUID]?
    }
}
