//
//  File.swift
//  
//
//  Created by Nicolas on 12/04/2021.
//

import Foundation
import Vapor
import Fluent

struct ProfilePictureController {
    
    func getPicture(req: Request) throws -> Response {
        let user = try req.auth.require(User.self)
        guard let picture = user.picture else {throw Abort(HTTPStatus.badRequest)}
        let path = req.application.directory.publicDirectory + "profile/" + picture
        let input = req.fileio.streamFile(at: path)
        return input
    }
    
    func getPictureByPath(req: Request, path:String) -> Response{
        let path = path
        let input = req.fileio.streamFile(at: path)
        return input
    }
    
    func uploadPicture(req: Request) throws -> EventLoopFuture<Response> {
        struct Input: Content {
            var file: File
        }
        
        let user = try req.auth.require(User.self)
        print("USER OK")
        let input = try req.content.decode(Input.self)
        print("INPUT OK")
        guard input.file.data.readableBytes > 0 else { throw Abort(.badRequest) }
        
        let path = req.application.directory.publicDirectory + "profile/" + input.file.filename
        print(path)
        return req.application.fileio.openFile(path: path,
                                               mode: .write,
                                               flags: .allowFileCreation(posixMode: 0x744),
                                               eventLoop: req.eventLoop)
            .flatMap { (handle)  in
                return req.application.fileio.write(fileHandle: handle,
                                                    buffer: input.file.data,
                                                    eventLoop: req.eventLoop).flatMapThrowing {() -> EventLoopFuture<Void> in
                                                        
                                                        try handle.close()
                                                        user.picture = input.file.filename
                                                        return user.update(on: req.db)
                                                    }.map { (_)  in
                                                        return getPictureByPath(req: req, path: path)
                                                    }
                
            }
    }
}


