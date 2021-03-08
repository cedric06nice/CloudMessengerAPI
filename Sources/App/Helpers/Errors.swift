//
//  File.swift
//  
//
//  Created by cedric06nice on 07/03/2021.
//

import Vapor

enum UserError {
    case created
    case nameTaken
    case emailTaken
}

extension UserError: AbortError {
    var description: String {
        reason
    }
    
    var status: HTTPResponseStatus {
        switch self {
            case .created: return .ok
            case .nameTaken: return .conflict
            case .emailTaken: return .conflict
        }
    }
    
    var reason: String {
        switch self {
            case .created: return "User created"
            case .nameTaken: return "Name already taken"
            case .emailTaken: return "Email already registered"
        }
    }
}
