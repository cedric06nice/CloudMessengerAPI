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
        let pictureName = try? req.query.decode(PictureName.self)
        if let picture = pictureName {
            let path = req.application.directory.publicDirectory + "profile/" + (picture.picture)
            let input = req.fileio.streamFile(at: path)
            return input
        }else {
            print("picturename null")
            guard let userPicture = user.picture else {throw Abort(.badRequest)}
            let path = req.application.directory.publicDirectory + "profile/" + userPicture
            let input = req.fileio.streamFile(at: path)
            return input
        }
        
        }
    
    func getifPicture(req: Request) throws -> HTTPStatus {
        let user = try req.auth.require(User.self)
        let pictureName = try? req.query.decode(PictureName.self)
        if let picture = pictureName {
            let path = req.application.directory.publicDirectory + "profile/" + (picture.picture)
            let file = FileManager.default.fileExists(atPath: path)
            print(file)
            if file {
                return HTTPResponseStatus.ok
            }else {
                return HTTPResponseStatus.badRequest
            }
        }
        else {
            print("picturename null")
            guard let userPicture = user.picture else {throw Abort(.badRequest)}
            let path = req.application.directory.publicDirectory + "profile/" + userPicture
            let file = FileManager.default.fileExists(atPath: path)
            if file {
                return HTTPResponseStatus.ok
            }else {
                return HTTPResponseStatus.badRequest
            }
        }
        
        }
    
    func uploadPicture(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        struct Input: Content {
            var file: File
        }
        
        let user = try req.auth.require(User.self)
        let input = try req.content.decode(Input.self)
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
                                                    }.map{ (_)  in
                                                        return HTTPStatus.ok
                                                    }
                
            }
    }
}

struct PictureName : Content {
    let picture:String
}
struct Output:Content {
    let file:File
}

