//
//  File.swift
//  
//
//  Created by Nicolas on 06/04/2021.
//

import Foundation
import Fluent

class UpdateMessageIsRead : Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Constants.Message.schema).field(Constants.Message.FieldKeys.isPicture, .bool, .sql(.default(false)), .required).update()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Constants.Message.schema).delete()
    }
}
