//
//  File.swift
//  
//
//  Created by cedric06nice on 07/03/2021.
//

import Fluent

struct CreateMessage: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Constants.Message.schema)
            .id()
            .field(Constants.Message.FieldKeys.timestamp, .datetime, .required)
            .field(Constants.Message.FieldKeys.message, .string, .required)
            .field(Constants.Message.FieldKeys.ownerId, .uuid, .required, .references("users", "id"))
            .field(Constants.Message.FieldKeys.flag, .bool)
            .field(Constants.Message.FieldKeys.isPicture, .bool)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Constants.Message.schema).delete()
    }
}
