//
//  File.swift
//  
//
//  Created by Nicolas on 10/04/2021.
//

import Fluent

struct CreateChannel: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Constants.Channel.schema)
            .id()
            .field(Constants.Channel.FieldKeys.channelName, .string, .required)
            .field(Constants.Channel.FieldKeys.channel_user, .array(of: .uuid))
            .field(Constants.Channel.FieldKeys.channel_isPublic, .bool)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Constants.Message.schema).delete()
    }
}
