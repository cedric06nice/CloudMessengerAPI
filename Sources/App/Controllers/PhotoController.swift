//
//  File.swift
//  
//
//  Created by cedric06nice on 04/04/2021.
//

import Fluent
import Vapor

struct PhotoController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let photoRoute = routes.grouped("photos")
        let tokenProtected = photoRoute.grouped(UserToken.authenticator(),
                                                UserToken.guardMiddleware())
        tokenProtected.post("upload-picture", use: uploadPicture)
    }
    
    fileprivate func uploadPicture(req: Request) throws -> EventLoopFuture<String> {
        try req.auth.require(User.self)
        
        struct Input: Content {
            var file: File
        }
        let input = try req.content.decode(Input.self)
        guard input.file.data.readableBytes > 0 else { throw Abort(.badRequest) }
        
        let path = req.application.directory.publicDirectory + input.file.filename
        return req.application.fileio.openFile(path: path,
                                               mode: .write,
                                               flags: .allowFileCreation(posixMode: 0x744),
                                               eventLoop: req.eventLoop)
            .flatMap { handle in
                req.application.fileio.write(fileHandle: handle,
                                             buffer: input.file.data,
                                             eventLoop: req.eventLoop)
                    .flatMapThrowing { _ in
                        try handle.close()
                        print("Picture uploaded : " + path)
                        return path
                    }
            }
    }
}
