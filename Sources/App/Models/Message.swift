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
    @Parent(key: Constants.Message.FieldKeys.ownerId) var ownerId: User.IDValue
    @Field(key: Constants.Message.FieldKeys.subject) var subject: String
    @Field(key: Constants.Message.FieldKeys.flag) var flag: Bool?
    
    init() { }
    
    init(id: UUID? = nil,
         ownerId: User.IDValue,
         subject: String,
         flag: Bool? = nil) {
        self.id = id
        self.ownerId = owner
        self.subject = subject
        self.flag = flag
    }
}
