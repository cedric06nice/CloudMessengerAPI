//
//  File.swift
//  
//
//  Created by cedric06nice on 07/03/2021.
//

import Fluent
import Vapor

final class Message: Model, Content {
    static let schema = Constants.Message.schema
    
    @ID(key: .id) var id: UUID?
    @Timestamp(key: Constants.Message.FieldKeys.timestamp, on: .create) var timestamp: Date?
    @Parent(key: Constants.Message.FieldKeys.owner) var owner: User
    @Field(key: Constants.Message.FieldKeys.subject) var subject: String

    init() { }
    
    init(id: UUID? = nil,
         owner: User.IDValue,
         subject: String) {
        self.id = id
        self.owner.id = owner
        self.subject = subject
    }
}
