//
//  File.swift
//  
//
//  Created by Quentin ROLLAND on 05/01/2021.
//

import Fluent
import Vapor

enum SessionSource: Int, Content {
    case signup
    case login
}

final class UserToken: Model, Content {
    static let schema = Constants.Token.schema

    @ID(key: .id) var id: UUID?
    @Field(key: Constants.Token.FieldKeys.value) var value: String
    @Parent(key: Constants.Token.FieldKeys.user) var user: User
    @Timestamp(key: Constants.Token.FieldKeys.createdAt, on: .create) var createdAt: Date?
    @Field(key: Constants.Token.FieldKeys.expiresAt) var expiresAt: Date?
    @Field(key: Constants.Token.FieldKeys.source) var source: SessionSource

    init() { }
    
    init(id: UUID? = nil,
         token: String,
         userId: User.IDValue,
         expiresAt: Date?,
         source: SessionSource) {
        self.id = id
        self.value = token
        self.$user.id = userId
        self.source = source
        self.expiresAt = expiresAt
    }
}

extension UserToken: ModelTokenAuthenticatable {
    static let valueKey = \UserToken.$value
    static let userKey = \UserToken.$user
    
    var isValid: Bool {
        guard let expiryDate = expiresAt else {
            return true
        }
        return expiryDate > Date()
    }
}
