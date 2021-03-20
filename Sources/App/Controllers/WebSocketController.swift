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
    var storage: [WebSocket] = []
    
    func addWs(ws: WebSocket) {
        storage.append(ws)
    }
    
    //lorsque j'appelle cette fonction j'envoie un message à toutes les personnes connecté
    func sendMessageForAll(message: String) {
        for ws in storage {
            ws.send(message)
        }
    }
    
    
    //Lorsqu'on recoit du texte on l'ananlyse, on verify si c'est un message...
    func onReceive(ws: WebSocket, req: Request, text: String) throws {
        if text == "get-all-messages" {
            //var messagesLoaded : [Message.MessageToSend] = []
            let messages = req.db.query(Message.self).all().map({ (messages) -> [Message.MessageToSend?] in
                return messages.map { (message) -> Message.MessageToSend? in
                    return try? message.$owner.load(on: req.db).map { (_) -> Message.MessageToSend? in
                        guard let user = message.$owner.value,
                              let messageID = message.id,
                              let timestamp = message.timestamp
                        else{return nil}
                        return Message.MessageToSend(id: messageID, subject: message.subject, timestamp: timestamp, user: user)
                    }.wait()
                    }
            }).map({ (optionalArrayMessageToSend) in
                if optionalArrayMessageToSend.contains(where: { (messageOptional) -> Bool in
                    return messageOptional == nil
                }){}else{
                    let messages = optionalArrayMessageToSend.map { (messagesOptional) -> Message.MessageToSend in
                        return messagesOptional!
                    }
                }
            })
        }
    
        
        if let jsonText = text.data(using: .utf8) {
            if let message = try? JSONDecoder().decode(Message.self, from: jsonText){
                message.save(on: req.db) //...Si on à bien un message on l'enregistre dans la base de donées
                var messagesLoaded : [Message.MessageToSend] = []
                //On vient donc de recevoir un message il faut donc renvoyer tous les messages aux utilisateurs
                let messages = try req.db.query(Message.self).all().wait()
                let messagesToSend = try messages.map { (message) -> Message.MessageToSend in
                    try message.$owner.load(on: req.db).wait()
                    guard let user = message.$owner.value, let messageID = message.id else {throw Abort(.conflict)}
                    if let timestamp = message.timestamp {
                        return Message.MessageToSend(id: messageID, subject: message.subject, timestamp: timestamp, user: user)
                }
                    throw Abort(.conflict)
                }
                guard let allMessagesJson = try? JSONEncoder().encodeToString(messagesToSend)else {print("echec conversion tableau message to send en json");return}
                self.sendMessageForAll(message: allMessagesJson)
                
            }
        }
    }
    
    func WebSocketsManagement(ws: WebSocket, req: Request) {
        do {
            let user = try req.auth.require(User.self) // /!\ Attention le fait de passer par un TokenGroup ne vous empêche pas d'accèder à la connexion au WebSocket c'est pourquoi ici je verifie si je peut recupérer un user et sinon j'envoie un message et je ferme la connexion
            addWs(ws: ws) //ajout d'un WebSocket à chaque connexion d'un utilisateur different.
            ws.onText { (ws, text) in
                try? self.onReceive(ws: ws, req: req, text: text)
            }
        }catch {
            ws.send("Unauthorized !")
            ws.close()
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
        let subject:String
        let timestamp: Date
        let username:String
        let userID:UUID?
        init(id:UUID, subject:String, timestamp:Date, user:User) {
            self.id = id
            self.subject = subject
            self.username = user.name
            self.userID = user.id
            self.timestamp = timestamp
        }
    }
}
