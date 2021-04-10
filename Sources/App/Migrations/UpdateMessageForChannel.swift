//
//  File.swift
//  
//
//  Created by Nicolas on 10/04/2021.
//

import Foundation
import Fluent
class UpdateMessageForChannel : Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Constants.Message.schema)
            .field(Constants.Message.FieldKeys.channel, .uuid)
            .update()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Constants.Message.schema).deleteField(Constants.Message.FieldKeys.channel).update()
    }
}
