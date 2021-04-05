//
//  File.swift
//  
//
//  Created by cedric06nice on 07/03/2021.
//

import Fluent

struct Constants {
    struct Users {
        static var schema = "users"
        struct FieldKeys {
            static var name: FieldKey = "name"
            static var email: FieldKey = "email"
            static var password: FieldKey = "password"
            static var passwordHash: FieldKey = "password_hash"
            static var createdAt: FieldKey = "created_at"
            static var flag: FieldKey = "flag"
            static var isModerator: FieldKey = "is_moderator"
            static var isActive: FieldKey = "is_active"
            static var picture: FieldKey = "picture"
            static var description: FieldKey = "description"
        }
        struct FieldKeysAsString {
            static var name = "name"
            static var email = "email"
            static var password = "password"
            static var passwordHash = "password_hash"
            static var createdAt = "created_at"
            static var flag = "flag"
            static var isModerator = "is_moderator"
            static var isActive = "is_active"
            static var picture = "picture"
            static var description = "description"
        }
    }
    struct Token {
        static var schema = "user_tokens"
        struct FieldKeys {
            static var value: FieldKey = "value"
            static var user: FieldKey = "user_id"
            static var createdAt: FieldKey = "created_at"
            static var expiresAt: FieldKey = "expires_at"
            static var source: FieldKey = "source"
        }
        struct FieldKeysAsString {
            static var value = "value"
            static var user = "user_id"
            static var createdAt = "created_at"
            static var expiresAt = "expires_at"
        }
    }
    struct Message {
        static var schema = "messages"
        struct FieldKeys {
            static var timestamp: FieldKey = "timestamp"
            static var ownerId: FieldKey = "owner_id"
            static var message: FieldKey = "message"
            static var flag: FieldKey = "flag"
            static var isPicture: FieldKey = "is_picture"
        }
        struct FieldKeysAsString {
            static var timestamp = "timestamp"
            static var ownerId = "owner_id"
            static var message = "message"
            static var flag = "flag"
            static var isPicture = "is_picture"
        }
    }
}
