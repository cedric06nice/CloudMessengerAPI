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
    @Parent(key: Constants.Message.FieldKeys.ownerId) var ownerId: User
    @Field(key: Constants.Message.FieldKeys.message) var message: String
    @Field(key: Constants.Message.FieldKeys.flag) var flag: Bool?
    
    init() { }
    
    init(id: UUID? = nil,
         ownerId: User.IDValue,
         message: String,
         flag: Bool? = nil) {
        self.id = id
        self.$ownerId.id = ownerId
        self.message = message
        self.flag = flag
    }
}
