//
//  File.swift
//  
//
//  Created by Quentin ROLLAND on 05/01/2021.
//

import Fluent
import Vapor

struct UserSignup: Content {
    let name: String
    let email: String
    let password: String
    let isModerator: Bool
    let isActive: Bool
}

struct NewSession: Content {
    let token: String
    let user: User.Public
}

struct UserUpdatePassword: Content {
    let currentPassword: String
    let newPassword: String
}

extension UserSignup: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("name", as: String.self, is: !.empty && .alphanumeric && .count(3...))
        validations.add("email", as: String.self, is: !.empty && .email)
        validations.add("password", as: String.self, is: .count(6...))
    }
}

struct UserController: RouteCollection {
    let profilePictureController = ProfilePictureController()
    func boot(routes: RoutesBuilder) throws {
        let usersRoute = routes.grouped("users")
        usersRoute.post("signup", use: create)
        
        let passwordProtected = usersRoute.grouped(User.authenticator())
        passwordProtected.post("login", use: login)
        
        let tokenProtected = usersRoute.grouped(UserToken.authenticator(), UserToken.guardMiddleware())
        tokenProtected.get("me", use: getOwnUser)
        tokenProtected.get("all-users", use: getAllUsers)
        tokenProtected.post("profile-picture", use: profilePictureController.uploadPicture)
        tokenProtected.get("profile-picture", use: profilePictureController.getPicture)
        tokenProtected.get("canGetPicture", use: profilePictureController.getifPicture)
        tokenProtected.post("update-password", use: updatePassword)
    }
    
    
    
    fileprivate func create(req: Request) throws -> EventLoopFuture<NewSession> {
        try UserSignup.validate(content: req)
        let userSignup = try req.content.decode(UserSignup.self)
        let user = try User.create(from: userSignup)
        var token: UserToken!
        
        return checkIfEmailExists(userSignup.email, req: req).flatMap { emailExists in
            guard emailExists else {
                return req.eventLoop.future(error: UserError.emailTaken)
            }
            
            return checkIfNameExists(userSignup.name, req: req).flatMap { nameExists in
                guard nameExists else {
                    return req.eventLoop.future(error: UserError.nameTaken)
                }
                return user.save(on: req.db)
            }
        }.flatMap {
            guard let newToken = try? user.createToken(source: .signup) else {
                return req.eventLoop.future(error: Abort(.internalServerError))
            }
            token = newToken
            return token.save(on: req.db)
        }.flatMapThrowing {
            NewSession(token: token.value, user: try user.asPublic())
        }
    }
    
    fileprivate func login(req: Request) throws -> EventLoopFuture<NewSession> {
        let user = try req.auth.require(User.self)
        let token = try user.createToken(source: .login)
        
        return token.save(on: req.db)
            .flatMapThrowing {
                NewSession(token: token.value, user: try user.asPublic())
            }
    }
    
    fileprivate func getOwnUser(req: Request) throws -> User {
        try req.auth.require(User.self)
    }
    
    fileprivate func getAllUsers(req: Request) throws -> EventLoopFuture<[User.Public]> {
        return User.query(on: req.db).all()
            .flatMapThrowing { (fullUserList: [User]) -> [User.Public] in
                var result = [User.Public]()
                for publicUser in fullUserList {
                    try result.append(publicUser.asPublic())
                }
                return result
            }
    }
    
    fileprivate func checkIfEmailExists(_ email: String, req: Request) -> EventLoopFuture<Bool> {
        User.query(on: req.db)
            .filter(\.$email == email)
            .first()
            .map { $0 == nil }
    }
    
    fileprivate func checkIfNameExists(_ name: String, req: Request) -> EventLoopFuture<Bool> {
        User.query(on: req.db)
            .filter(\.$name == name)
            .first()
            .map { $0 == nil }
    }
    
    fileprivate func updatePassword(req: Request) throws -> HTTPStatus {
        let user = try req.auth.require(User.self)
        let userUpdatePassword = try req.content.decode(UserUpdatePassword.self)
        if try user.verify(password: userUpdatePassword.currentPassword) {
            user.passwordHash = try Bcrypt.hash(userUpdatePassword.newPassword)
            _ = user.update(on: req.db)
                .map { return HTTPStatus.ok}
        }
        return HTTPStatus.unauthorized
    }
}
