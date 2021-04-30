//
//  File.swift
//  
//
//  Created by Nicolas on 30/04/2021.
//

import Foundation
import Fluent

class UpdateFieldMessages: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Constants.Message.schema)
            .updateField(Constants.Message.FieldKeys.message,
            .sql(raw: "TEXT")).update()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Constants.Message.schema)
            .updateField(Constants.Message.FieldKeys.message, .string)
            .update()
    }
    
    
}
