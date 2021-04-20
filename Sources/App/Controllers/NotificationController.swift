//
//  File.swift
//  
//
//  Created by Nicolas on 20/04/2021.
//

import Foundation
import FCM
import Vapor

class NotificationController {
    public func sendNotificationToGeneral(title:String, body:String, req: Request) -> EventLoopFuture<String>{
        return send(title: title, body: body, topic: "general", req: req)
    }
    
    public func sendNotificationToModerator(title:String, body:String, req:Request) -> EventLoopFuture<String>{
        return send(title: title, body: body, topic: "moderator", req: req)
    }
    
    
    private func send(title:String, body:String, topic:String, req:Request) -> EventLoopFuture<String> {
        let notification = FCMNotification(title: title, body: body)
        let message = FCMMessage(condition: "'\(topic)' in topics", notification: notification, apns: FCMApnsConfig(headers: [:], aps: FCMApnsApsObject(badge: 1, sound: "default")))
        //let message = FCMMessage(condition: "'general' in topics", notification: notification)
        return req.fcm.send(message).map { (name) in
            return name
        }
    }
}
