//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 18.07.2021.
//

import Vapor
import Fluent


public extension ResourceController {
    func create<Input, Model>(
        req: Request,
        using: Input.Type) throws -> EventLoopFuture<Output>
    where
        Input: ResourceUpdateModel,
        Output.Model == Model,
        Input.Model == Output.Model {

        try Input.validate(content: req)
        let inputModel = try req.content.decode(Input.self)

        return req.db.tryTransaction { db in
            inputModel
                .update(Output.Model(), req: req, database: db)
                .flatMap { $0.save(on: db).transform(to: $0) }
                .flatMapThrowing { try Output($0, req: req) }
        }
    }
    
    @available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
    func create<Input, Model>(
        req: Request,
        using: Input.Type) async throws -> Output
    where
        Input: AsyncResourceUpdateModel,
        Output.Model == Model,
        Input.Model == Output.Model {

            try Input.validate(content: req)
            let inputModel = try req.content.decode(Input.self)

            return try await req.db.transaction { db in
                let model = try await inputModel
                    .update(Output.Model(), req: req, database: db)
                try await model.save(on: db)
                return try Output(model, req: req)
            }
    }
}

public extension RelatedResourceController {
    func create<Input, Model, RelatedModel>(
        resolver: Resolver<RelatedModel> = .byIdKeys,
        req: Request,
        using: Input.Type,
        willAttach middleware: ControllerMiddleware<Model, RelatedModel> = .empty,
        relationKeyPath: ChildrenKeyPath<RelatedModel, Model>) throws -> EventLoopFuture<Output>
    where
        Input: ResourceUpdateModel,
        Model == Output.Model,
        Input.Model == Output.Model {

        try Input.validate(content: req)
        let inputModel = try req.content.decode(Input.self)
        return req.db.tryTransaction { db in

            try resolver
                .find(req, db)
                .and(inputModel.update(Output.Model(), req: req, database: db))
                .flatMap { (related, model) in middleware.handle(model,
                                                                        relatedModel: related,
                                                                        req: req,
                                                                        database: db) }
                .flatMapThrowing { (model, related) in try model.attached(to: related, with: relationKeyPath) }
                .flatMap { model in model.save(on: db).transform(to: model) }
                .flatMapThrowing { try Output($0, req: req) }
        }
    }

    @available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
    func create<Input, Model, RelatedModel>(
        resolver: AsyncResolver<RelatedModel> = .byIdKeys,
        req: Request,
        using: Input.Type,
        willAttach middleware: AsyncControllerMiddleware<Model, RelatedModel> = .empty,
        relationKeyPath: ChildrenKeyPath<RelatedModel, Model>) async throws -> Output
    where
        Input: AsyncResourceUpdateModel,
        Model == Output.Model,
        Input.Model == Output.Model {
            
            try Input.validate(content: req)
            let inputModel = try req.content.decode(Input.self)
            return try await req.db.transaction { db in
                let (model, related) = try await middleware.handle(try await inputModel.update(Output.Model(), req: req, database: db),
                                            relatedModel: try await resolver.find(req, db),
                                            req: req,
                                            database: db)
                try model.attached(to: related, with: relationKeyPath)
                try await model.save(on: db)
                
                return try Output(model, req: req)
            }
    }

    func create<Input, Model, RelatedModel>(
        resolver: Resolver<RelatedModel> = .byIdKeys,
        req: Request,
        using: Input.Type,
        willAttach middleware: ControllerMiddleware<Model, RelatedModel> = .empty,
        relationKeyPath: ChildrenKeyPath<Model, RelatedModel>) throws -> EventLoopFuture<Output>
    where
        Input: ResourceUpdateModel,
        Model == Output.Model,
        Input.Model == Output.Model {

        try Input.validate(content: req)
        let inputModel = try req.content.decode(Input.self)
        let keyPath = relationKeyPath
        return req.db.tryTransaction { db in

            try resolver
                .find(req, db)
                .and(inputModel.update(Output.Model(), req: req, database: db))
                .flatMap { (related, model) in middleware.handle(model,
                                                                        relatedModel: related,
                                                                        req: req,
                                                                        database: db) }
                .flatMap { (model, related) in  model.save(on: db).transform(to: (model, related)) }
                .flatMapThrowing { (model, related) in (try model.attached(to: related, with: keyPath), related) }
                .flatMap { (model, related) in [related.save(on: db), model.save(on: db)]
                    .flatten(on: db.context.eventLoop)
                    .transform(to: model) }
                .flatMapThrowing { try Output($0, req: req)}
        }
    }
    
    @available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
    func create<Input, Model, RelatedModel>(
        resolver: AsyncResolver<RelatedModel> = .byIdKeys,
        req: Request,
        using: Input.Type,
        willAttach middleware: AsyncControllerMiddleware<Model, RelatedModel> = .empty,
        relationKeyPath: ChildrenKeyPath<Model, RelatedModel>) async throws -> Output
    where
        Input: AsyncResourceUpdateModel,
        Model == Output.Model,
        Input.Model == Output.Model {
            
            try Input.validate(content: req)
            let inputModel = try req.content.decode(Input.self)
            let keyPath = relationKeyPath

            return try await req.db.transaction { db in
                let (model, related) = try await middleware.handle(try await inputModel.update(Output.Model(), req: req, database: db),
                                            relatedModel: try await resolver.find(req, db),
                                            req: req,
                                            database: db)
                try await model.save(on: db)
                try model.attached(to: related, with: keyPath)
                try await model.save(on: db)
                try await related.save(on: db)

                return try Output(model, req: req)
            }
        }

    func create<Input, Model, RelatedModel, Through>(
        resolver: Resolver<RelatedModel> = .byIdKeys,
        req: Request,
        using: Input.Type,
        willAttach middleware: ControllerMiddleware<Model, RelatedModel> = .empty,
        relationKeyPath: SiblingKeyPath<RelatedModel, Model, Through>) throws -> EventLoopFuture<Output>
    where
        Input: ResourceUpdateModel,
        Model == Output.Model,
        Input.Model == Output.Model,
        Through: Fluent.Model {

        try Input.validate(content: req)
        let inputModel = try req.content.decode(Input.self)
        return req.db.tryTransaction { db in

            try resolver
                .find(req, db)
                .and(inputModel.update(Output.Model(), req: req, database: db))
                .flatMap { (related, model) in middleware.handle(model,
                                                                                       relatedModel: related,
                                                                                       req: req,
                                                                                       database: db) }
                .flatMap { (model, related) in model.save(on: db).transform(to: (model, related)) }
                .flatMap { (model, related) in model.attached(to: related, with: relationKeyPath, on: db) }
                .flatMapThrowing { try Output($0, req: req) }
        }
    }
    
    @available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
    func create<Input, Model, RelatedModel, Through>(
        resolver: AsyncResolver<RelatedModel> = .byIdKeys,
        req: Request,
        using: Input.Type,
        willAttach middleware: AsyncControllerMiddleware<Model, RelatedModel> = .empty,
        relationKeyPath: SiblingKeyPath<RelatedModel, Model, Through>) async throws -> Output
    where
        Input: AsyncResourceUpdateModel,
        Model == Output.Model,
        Input.Model == Output.Model,
        Through: Fluent.Model {

            try Input.validate(content: req)
            let inputModel = try req.content.decode(Input.self)

            return try await req.db.transaction { db in
                let (model, related) = try await middleware.handle(try await inputModel.update(Output.Model(), req: req, database: db),
                                            relatedModel: try await resolver.find(req, db),
                                            req: req,
                                            database: db)
                try await model.save(on: db)
                try await model.attached(to: related, with: relationKeyPath, on: db)

                return try Output(model, req: req)
            }
        }
}
