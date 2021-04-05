//
//  File.swift
//  
//
//  Created by Nicolas on 13/03/2021.
//

import Foundation
import Vapor

class WebSocketController {
    //On crée un tableau vide à l'instance qui servira à recuillir tous les clients qui se connectent au serveur 
    var storage: [WebSocketWithId] = []
    var timer:Timer? = nil
    
    func addWs(webSocketWithID: WebSocketWithId) {
        storage.append(webSocketWithID)
    }
    
    //lorsque j'appelle cette fonction j'envoie un message à toutes les personnes connecté
    func sendMessageForAll(message: String) {
        for webSocketWithID in storage {
            webSocketWithID.ws.send(message)
        }
    }
    
    func getAllMessagesAndSendForAll(req: Request) {
        var messagesToSend : [Message.MessageToSend] = []
        _ = Message.query(on: req.db)
            .with(\.$ownerId)
            .sort(\.$timestamp, .ascending)
            .all()
            .map { (messages) in
                for message in messages {
                    if let id = message.id,
                       let user = message.$ownerId.value,
                       let timestamp = message.timestamp {
                        let messageToSend = Message.MessageToSend(id: id,
                                                                  message: message.message,
                                                                  timestamp: timestamp,
                                                                  user: user,
                                                                  flag: message.flag,
                                                                  isPicture: message.isPicture)
                        messagesToSend.append(messageToSend)
                    }
                }
                guard let allMessagesJson = try? JSONEncoder().encodeToString(messagesToSend) else {
                    print("echec conversion tableau message to send en json")
                    return
                }
                self.sendMessageForAll(message: allMessagesJson)
            }
    }
    
    
    //Lorsqu'on recoit du texte on l'ananlyse, on verify si c'est un message...
    func onReceive(ws: WebSocket, req: Request, text: String) throws {
        if text == "get-all-messages" {
            getAllMessagesAndSendForAll(req: req)
        }
        
        print("Text = " + text)
        
        if let jsonText = text.data(using: .utf8) {
            print("message recu")
            if let message = try? JSONDecoder().decode(Message.self, from: jsonText) {
                print("message decoded")
                _ = message.save(on: req.db) //...Si on à bien un message on l'enregistre dans la base de donées
                //On vient donc de recevoir un message il faut donc renvoyer tous les messages aux utilisateurs
                getAllMessagesAndSendForAll(req: req)
            }
        }
    }
    
    func WebSocketsManagement(ws: WebSocket, req: Request) {
        do {
            let _ = try req.auth.require(User.self)
            webSocketInit(webSocket: ws, req: req)
        }catch {
            ws.send("Unauthorized !")
            _ = ws.close()
        }
    }
    
    func webSocketInit(webSocket: WebSocket, req:Request){
        let webSocketWithID = WebSocketWithId(id: UUID(), ws: webSocket)
        addWs(webSocketWithID: webSocketWithID)
        webSocketWithID.ws.onText { (ws, text) in
            try? self.onReceive(ws: ws, req: req, text: text)
        }
        _ = webSocketWithID.ws.onClose.always { (_) in
            self.onClose(webSocketWithId: webSocketWithID)
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
        
        init(id:UUID,
             message:String,
             timestamp:Date,
             user:User,
             flag:Bool?,
             isPicture:Bool) {
            self.id = id
            self.message = message
            self.username = user.name
            self.userID = user.id
            self.timestamp = timestamp.timeIntervalSince1970
            self.flag = flag
            self.isPicture = isPicture
        }
    }
}


struct WebSocketWithId {
    let id:UUID
    let ws:WebSocket
}


