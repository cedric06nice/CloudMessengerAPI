//
//  File.swift
//  
//
//  Created by Nicolas on 13/03/2021.
//

import Foundation
import Vapor
import Fluent

class WebSocketController {
    //On crée un tableau vide à l'instance qui servira à recuillir tous les clients qui se connectent au serveur 
    var storage: [WebSocketWithId] = []
    var timer:Timer? = nil
    
    func WebSocketsManagement(ws: WebSocket, req: Request) {
        do {
            let _ = try req.auth.require(User.self)
            let channel = try? req.query.decode(WebSocketChannelOnInit.self)
            webSocketInit(webSocket: ws, req: req, channel: channel?.channel)
        }catch {
            ws.send("Unauthorized !")
            _ = ws.close()
        }
    }
    
    func webSocketInit(webSocket: WebSocket, req:Request, channel:UUID?){
        let webSocketWithID = WebSocketWithId(id: UUID(), ws: webSocket, channel: channel)
        addWs(webSocketWithID: webSocketWithID)
        webSocketWithID.ws.onText { (ws, text) in
            try? self.onReceive(ws: ws, req: req, text: text)
        }
        _ = webSocketWithID.ws.onClose.always { (_) in
            self.onClose(webSocketWithId: webSocketWithID)
        }
        getAllMessagesAndSendForAll(req: req, channel: channel)
    }
    
    func addWs(webSocketWithID: WebSocketWithId) {
        storage.append(webSocketWithID)
    }
    
    func sendMessageForAll(message: String, channel:UUID?) {
        for webSocketWithID in storage {
            if webSocketWithID.channel == channel {
                webSocketWithID.ws.send(message)
            }
        }
    }
    
    
    func getAllMessagesAndSendForAll(req: Request, channel: UUID?) {
        _ = Message.query(on: req.db)
            .filter(\.$channel == channel)
            .with(\.$ownerId)
            .sort(\.$timestamp, .ascending)
            .all()
            .flatMapThrowing { (messageArray) -> [Message.MessageToSend]  in
                return try messageArray.map { (message) -> Message.MessageToSend in
                    Message.MessageToSend(id: try message.requireID(), message: message.message, timestamp: message.timestamp ?? Date(), user: message.ownerId, flag: message.flag, isPicture: message.isPicture ?? false, channel: message.channel, ownerPicture: message.ownerId.picture)
                }
            }.flatMapThrowing{ (messagesForSendingArray) in
                guard let messagesForSendingJson = try? JSONEncoder().encodeToString(messagesForSendingArray) else{throw Abort(HTTPResponseStatus.conflict, reason: "Internal Serveur Error: Cant't convert message to json.")}
                self.sendMessageForAll(message: messagesForSendingJson, channel: channel)
            }
    }
    
    func onReceive(ws: WebSocket, req: Request, text: String) throws {
        if text == "get-all-messages" {
            getAllMessagesAndSendForAll(req: req, channel: nil)
        }
        
        
        if let jsonText = text.data(using: .utf8) {
            if let message = try? JSONDecoder().decode(Message.self, from: jsonText) {
                _ = message.save(on: req.db)
                getAllMessagesAndSendForAll(req: req, channel: message.channel)
            }
        }
    }
    
    func onClose(webSocketWithId:WebSocketWithId) {
        if storage.count > 0 {
            storage.removeAll { (wsId) -> Bool in
                return wsId.id == webSocketWithId.id
            }
        }
    }
}

//Cette extension nous permet de recevoir un objet et de le parser en JSONText plutôt que en tableau de donées
extension JSONEncoder {
    func encodeToString<T:Codable>(_ value : T) throws -> String {
        let data = try encode(value)
        return String(data: data, encoding: .utf8) ?? ""
    }
}

//On ajoute une extension à Message pour pouvoir envoyé les données en Json qui nous interesse
extension Message {
    struct MessageToSend : Content{
        let id:UUID
        let message:String
        let timestamp:Double
        let username:String
        let userID:UUID?
        let flag:Bool?
        let isPicture:Bool
        let channel:UUID?
        let owner_picture: String?
        
        init(id:UUID,
             message:String,
             timestamp:Date,
             user:User,
             flag:Bool?,
             isPicture:Bool,
             channel:UUID? = nil,
             ownerPicture: String?) {
            self.id = id
            self.message = message
            self.username = user.name
            self.userID = user.id
            self.timestamp = timestamp.timeIntervalSince1970
            self.flag = flag
            self.isPicture = isPicture
            self.owner_picture = ownerPicture
            
            
            if channel != nil{
                self.channel = channel!
            }else {
                self.channel = nil
            }
            
        }
    }
}

struct WebSocketWithId {
    let id:UUID
    let ws:WebSocket
    let channel: UUID?
    init(id:UUID, ws:WebSocket, channel : UUID? = nil) {
        self.id = id
        self.ws = ws
        self.channel = channel
    }
}

struct getMessageByChan : Content {
    var requestQuerie:String
    var channel:UUID?
}

struct WebSocketChannelOnInit : Content {
    let channel:UUID?
    init(channel: UUID? = nil){
        self.channel = channel
    }
}
