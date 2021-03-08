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
            static var password_hash: FieldKey = "password_hash"
            static var created_at: FieldKey = "created_at"
        }
        struct FieldKeysAsString {
            static var name = "name"
            static var email = "email"
            static var password = "password"
            static var password_hash = "password_hash"
            static var created_at = "created_at"
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
            static var owner: FieldKey = "owner"
            static var subject: FieldKey = "subject"
        }
        struct FieldKeysAsString {
            static var timestamp = "timestamp"
            static var owner = "owner"
            static var subject = "subject"
        }
    }
}
