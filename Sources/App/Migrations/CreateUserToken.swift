//
//  File.swift
//  
//
//  Created by Quentin ROLLAND on 05/01/2021.
//

import Fluent

struct CreateUserToken: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Constants.Token.schema)
            .id()
            .field(Constants.Token.FieldKeys.value, .string, .required)
            .field(Constants.Token.FieldKeys.user, .uuid, .required, .references("users", "id"))
            .field(Constants.Token.FieldKeys.createdAt, .datetime, .required)
            .field(Constants.Token.FieldKeys.expiresAt, .datetime)
            .field(Constants.Token.FieldKeys.source, .int, .required)
            .unique(on: Constants.Token.FieldKeys.value)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Constants.Token.schema).delete()
    }
}
