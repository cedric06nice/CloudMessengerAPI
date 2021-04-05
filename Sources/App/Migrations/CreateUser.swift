//
//  File.swift
//  
//
//  Created by Quentin ROLLAND on 05/01/2021.
//

import Fluent

struct CreateUser: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Constants.Users.schema)
            .id()
            .field(Constants.Users.FieldKeys.name, .string, .required)
            .field(Constants.Users.FieldKeys.email, .string, .required)
            .field(Constants.Users.FieldKeys.passwordHash, .string, .required)
            .field(Constants.Users.FieldKeys.createdAt, .datetime, .required)
            .field(Constants.Users.FieldKeys.isModerator, .bool, .required)
            .field(Constants.Users.FieldKeys.isActive, .bool, .required)
            .field(Constants.Users.FieldKeys.picture, .string)
            .field(Constants.Users.FieldKeys.description, .string)
            .unique(on: Constants.Users.FieldKeys.email)
            .unique(on: Constants.Users.FieldKeys.name)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Constants.Users.schema).delete()
    }
}
