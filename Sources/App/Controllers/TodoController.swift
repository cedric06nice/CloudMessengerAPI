import Fluent
import Vapor

//struct TodoController: RouteCollection {
//    func boot(routes: RoutesBuilder) throws {
//        let tokenGroup = routes.grouped(UserToken.authenticator()).grouped(UserToken.guardMiddleware())
//        tokenGroup.get("todos", use: index)
//        tokenGroup.get("todos", "count", use: count)
//        tokenGroup.post("todos", use: create)
//        tokenGroup.patch("todos", ":todoID", use: update)
//        tokenGroup.group("todos", ":todoID") { todo in
//            todo.delete(use: delete)
//        }
//        
//    }
//
//    func index(req: Request) throws -> EventLoopFuture<[Todo]> {
//        try req.auth.require(User.self)
//        return Todo.query(on: req.db)
//            .sort(\.$title, .ascending)
//            .all()
//    }
//    
//    func count(req: Request) throws -> EventLoopFuture<Int> {
//        try req.auth.require(User.self)
//        return Todo.query(on: req.db).all().map { todosList -> Int in
//            todosList.count
//        }
//    }
//
//    func create(req: Request) throws -> EventLoopFuture<Todo> {
//        try req.auth.require(User.self)
//        let todo = try req.content.decode(Todo.self)
//        return todo.save(on: req.db).transform(to: todo)
//    }
//
//    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
//        try req.auth.require(User.self)
//        return Todo.find(req.parameters.get("todoID"), on: req.db)
//            .unwrap(or: Abort(.notFound))
//            .flatMap { $0.delete(on: req.db) }
//            .transform(to: .ok)
//    }
//    
//    func update(req: Request) throws -> EventLoopFuture<HTTPStatus> {
//        try req.auth.require(User.self)
//        guard let id = req.parameters.get("todoID", as: UUID.self) else {
//                 throw Abort(.badRequest)
//             }
//             let updatedTodo = try req.content.decode(Todo.self)
//             return Todo.find(id, on: req.db)
//                 .unwrap(or: Abort(.notFound))
//                 .flatMap { todo in
//                     todo.title = updatedTodo.title
//                     return todo.save(on: req.db)
//                        .transform(to: .ok)
//                 }
//    }
//}
