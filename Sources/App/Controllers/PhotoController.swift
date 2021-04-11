//
//  File.swift
//  
//
//  Created by cedric06nice on 04/04/2021.
//

import Fluent
import Vapor

struct PhotoController {
    
    func getPicture(req: Request) throws -> Response {
        struct Filename : Content {
            let filename: String
        }
        let filename = try req.query.decode(Filename.self)
        let path = req.application.directory.publicDirectory + filename.filename
        let input = req.fileio.streamFile(at: path)
        return input
    }
    
    
    func uploadPicture(req: Request, onUpload: @escaping (UUID?) -> Void) throws -> EventLoopFuture<HTTPStatus> {
        struct Input: Content {
            var file: File
        }
        
        let user = try req.auth.require(User.self)
        let input = try req.content.decode(Input.self)
        let channelID = try? req.query.decode(Message.ChannelID.self)
        guard input.file.data.readableBytes > 0 else { throw Abort(.badRequest) }
        
        let path = req.application.directory.publicDirectory + input.file.filename
        print(path)
        return req.application.fileio.openFile(path: path,
                                               mode: .write,
                                               flags: .allowFileCreation(posixMode: 0x744),
                                               eventLoop: req.eventLoop)
            .flatMap { handle in
                req.application.fileio.write(fileHandle: handle,
                                             buffer: input.file.data,
                                             eventLoop: req.eventLoop)
                    .flatMapThrowing { () in
                        try handle.close()
                        let message = Message.init(ownerId: try user.requireID(), message: input.file.filename, flag: nil, isPicture: true, channel: channelID?.channelID)
                        _ = message.save(on: req.db).map({ ()  in
                            onUpload(channelID?.channelID)
                        })
                        return HTTPStatus.ok
                    }
            }
    }
}

extension Message {
    struct ChannelID : Content{
        var channelID:UUID?
    }
}

