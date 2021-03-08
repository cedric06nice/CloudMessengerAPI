//
//  File.swift
//  
//
//  Created by Quentin ROLLAND on 05/01/2021.
//

import Fluent
import Vapor

final class User: Model, Content {
    
    struct Public: Content {
        let id: UUID
        let name: String
        let createdAt: Date?
    }
    
    static let schema = Constants.Users.schema
    
    @ID(key: .id) var id: UUID?
    @Field(key: Constants.Users.FieldKeys.name) var name: String
    @Field(key: Constants.Users.FieldKeys.email) var email: String
    @Field(key: Constants.Users.FieldKeys.password_hash) var passwordHash: String
    @Timestamp(key: Constants.Users.FieldKeys.created_at, on: .create) var createdAt: Date?
    
    init() { }
    
    init(id: UUID? = nil,
         name: String,
         email: String,
         passwordHash: String) {
        self.id = id
        self.name = name
        self.email = email
        self.passwordHash = passwordHash
    }
}

extension User {
    
    static func create(from userSignup: UserSignup) throws -> User {
        User(name: userSignup.name,
             email: userSignup.email,
             passwordHash: try Bcrypt.hash(userSignup.password))
    }

    func createToken(source: SessionSource) throws -> UserToken {
        let calendar = Calendar(identifier: .gregorian)
        let expiryDate = calendar.date(byAdding: .hour, value: 48, to: Date())
        return try UserToken(token: [UInt8].random(count: 16).base64,
                             userId: requireID(),
                             expiresAt: expiryDate,
                             source: source)
    }
    
    func asPublic() throws -> Public {
        Public(id: try requireID(),
               name: name,
               createdAt: createdAt)
    }
}

extension User: ModelAuthenticatable {
    static let usernameKey = \User.$name
    static let passwordHashKey = \User.$passwordHash
    
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.passwordHash)
    }
}
