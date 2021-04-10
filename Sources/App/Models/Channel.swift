//
//  File.swift
//  
//
//  Created by Nicolas on 10/04/2021.
//

import Fluent
import Vapor

final class Channel: Model, Content {
    static let schema = Constants.Channel.schema
    
    @ID(key: .id) var id: UUID?
    @Field(key: Constants.Channel.FieldKeys.channelName) var name: String
    @Field(key: Constants.Channel.FieldKeys.channel_user) var channelUser: [UUID]
    @Field(key: Constants.Channel.FieldKeys.channel_isPublic) var isPublic: Bool
    
    init() { }
    
    init(id: UUID? = nil,
         name: String,
         channelUser: [UUID],
         isPublic: Bool = true) {
        self.id = id
        self.name = name
        self.isPublic = isPublic
        self.channelUser = channelUser
    }
}
