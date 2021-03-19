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
    func onReceive(ws: WebSocket, req: Request, text: String)  {
        if text == "get-all-messages" {
            var messagesLoaded : [Message.MessageToSend] = []
            do {
                try req.db.query(Message.self).all().map { (messages) in
                    //On transforme nos messages en Message.MessageToSend pour qu'il est un bon format
                    for message in messages{
                            message.$owner.load(on: req.db).map {
                                //On charge les donnée du user qui a posté les message pour pouvoir les exploité /!\ Important dans vapor si on oublie de load -> Fatal Error
                                guard let user = message.$owner.value, let messageID = message.id else { print("erreur recup user ou id"); return}
                                if let timestamp = message.timestamp {
                                    let messageToSend = Message.MessageToSend(id: messageID, subject: message.subject, timestamp: timestamp, user: user)
                                    messagesLoaded.append(messageToSend)
                                }
                            }
                        
                        //Une fois notre tableau rempli de Messages.MessageToSend on peut l'envoyé à tous nos utilisateurs =)
                        
                        
                    }
                }.wait()
            }catch{}
            guard let allMessagesJson = try? JSONEncoder().encodeToString(messagesLoaded)else {return}
            self.sendMessageForAll(message: allMessagesJson)
        }
        
        if let jsonText = text.data(using: .utf8) {
            if let message = try? JSONDecoder().decode(Message.self, from: jsonText){
                message.save(on: req.db) //...Si on à bien un message on l'enregistre dans la base de donées
                var messagesLoaded : [Message.MessageToSend] = []
                //On vient donc de recevoir un message il faut donc renvoyer tous les messages aux utilisateurs
                do {
                    try req.db.query(Message.self).all().map { (messages) in
                        //On transforme nos messages en Message.MessageToSend pour qu'il est un bon format
                        for message in messages{
                                message.$owner.load(on: req.db).map {
                                    //On charge les donnée du user qui a posté les message pour pouvoir les exploité /!\ Important dans vapor si on oublie de load -> Fatal Error
                                    guard let user = message.$owner.value, let messageID = message.id else { print("erreur recup user ou id"); return}
                                    if let timestamp = message.timestamp {
                                        let messageToSend = Message.MessageToSend(id: messageID, subject: message.subject, timestamp: timestamp, user: user)
                                        messagesLoaded.append(messageToSend)
                                    }
                                }
                            
                            //Une fois notre tableau rempli de Messages.MessageToSend on peut l'envoyé à tous nos utilisateurs =)
                        }
                    }
                }catch{}
                guard let allMessagesJson = try? JSONEncoder().encodeToString(messagesLoaded)else {return}
                self.sendMessageForAll(message: allMessagesJson)
            }
        }
    }
    
    func WebSocketsManagement(ws: WebSocket, req: Request) {
        do {
            let user = try req.auth.require(User.self) // /!\ Attention le fait de passer par un TokenGroup ne vous empêche pas d'accèder à la connexion au WebSocket c'est pourquoi ici je verifie si je peut recupérer un user et sinon j'envoie un message et je ferme la connexion
            addWs(ws: ws) //ajout d'un WebSocket à chaque connexion d'un utilisateur different.
            ws.onText { (ws, text) in
                self.onReceive(ws: ws, req: req, text: text)
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
