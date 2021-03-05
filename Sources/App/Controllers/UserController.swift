//
//  File.swift
//  
//
//  Created by Quentin ROLLAND on 05/01/2021.
//

import Fluent
import Vapor

struct UserController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("users")
        users.post(use: create)
        let basicGroup = routes.grouped(User.authenticator()).grouped(User.guardMiddleware())
        basicGroup.post("login", use: login)
    }
    
    
    func create(req: Request) throws -> EventLoopFuture<User> {
        let receivedData = try req.content.decode(User.Create.self)
        let user = try User(name: receivedData.name, email: receivedData.email, passwordHash: Bcrypt.hash(receivedData.password))
        return user.save(on: req.db).transform(to: user)
    }
    
    func login(req: Request) throws -> EventLoopFuture<UserToken> {
        let user = try req.auth.require(User.self)
        let token = try user.generateToken()
        return token.save(on: req.db).transform(to: token)
    }
}

extension User {
    struct Create: Content {
        var name: String
        var email: String
        var password: String
    }
}

extension User : ModelAuthenticatable {
    static var usernameKey = \User.$email
    
    static var passwordHashKey = \User.$passwordHash
    
    func verify(password: String) throws -> Bool {
        return try Bcrypt.verify(password, created: self.passwordHash)
    }
    
    func generateToken() throws -> UserToken {
        return try UserToken(value: [UInt8].random(count: 16).base64, userID: self.requireID())
    }
    
}


extension UserToken : ModelTokenAuthenticatable {
    static let valueKey = \UserToken.$value
    static let userKey = \UserToken.$user
    
    var isValid: Bool { true }
}
