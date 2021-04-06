//
//  File.swift
//  
//
//  Created by Nicolas on 06/04/2021.
//

import Foundation
import Fluent

class DBUpdatePicture : Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        _ = database.schema(Constants.Message.schema)
            .field(Constants.Message.FieldKeys.isPicture, .bool, .sql(.default(false)))
            .update()
                _ = database.schema(Constants.Users.schema)
                    .field(Constants.Users.FieldKeys.picture, .string)
                    .update()
                return database.schema(Constants.Users.schema)
                    .field(Constants.Users.FieldKeys.description, .string)
                    .update()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Constants.Message.schema).delete()
    }
}
