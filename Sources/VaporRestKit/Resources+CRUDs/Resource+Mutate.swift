//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 07.08.2021.
//

import Vapor
import Fluent
import NIOPosix

extension ResourceController {
    func mutate<Input, Model>(
        req: Request,
        using: Input.Type,
        queryModifier: QueryModifier<Model>) throws -> EventLoopFuture<Output>
    where
        Input: ResourceMutationModel,
        Output.Model == Model,
        Input.Model == Output.Model {
        
        try Input.validate(content: req)
        let inputModel = try req.content.decode(Input.self)
        
        return req.db.tryTransaction { db in
            try Model
                .findByIdKey(req, database: db, queryModifier: queryModifier)
                .flatMap { inputModel.mutate($0, req: req, database: db) }
                .flatMap { model in return model.save(on: db).transform(to: model) }
                .flatMapThrowing { try Output($0, req: req) }
        }
    }
    
    @available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
    func mutate<Input, Model>(
        req: Request,
        using: Input.Type,
        queryModifier: QueryModifier<Model>) async throws -> Output
    where
        Input: ResourceMutationModel,
        Output.Model == Model,
        Input.Model == Output.Model {
        
            try await mutate(req: req, using: using, queryModifier: queryModifier).get()
    }
}

extension RelatedResourceController {
    
    func mutate<Input, Model, RelatedModel>(
        resolver: ChildResolver<Model, RelatedModel>,
        req: Request,
        using: Input.Type,
        willSave middleware: ControllerMiddleware<Model, RelatedModel> = .empty,
        queryModifier: QueryModifier<Model>,
        relationKeyPath: ChildrenKeyPath<RelatedModel, Model>) throws -> EventLoopFuture<Output>
    where
        Input: ResourceMutationModel,
        Model == Output.Model,
        Model == Input.Model {
        
        try Input.validate(content: req)
        let inputModel = try req.content.decode(Input.self)
        return req.db.tryTransaction { db in
            
            try resolver
                .find(req, db, relationKeyPath, queryModifier)
                .flatMap { (model, related) in inputModel.mutate(model, req: req, database: db).and(value: related) }
                .flatMap { (model, related) in middleware.handle(model,
                                                                 relatedModel: related,
                                                                 req: req,
                                                                 database: db) }
                .flatMapThrowing { (model, related) in try model.attached(to: related, with: relationKeyPath) }
                .flatMap { model in model.save(on: db).transform(to: model) }
                .flatMapThrowing { try Output($0, req: req) }
        }
    }
    
    @available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
    func mutate<Input, Model, RelatedModel>(
        resolver: AsyncChildResolver<Model, RelatedModel>,
        req: Request,
        using: Input.Type,
        willSave middleware: AsyncControllerMiddleware<Model, RelatedModel> = .empty,
        queryModifier: QueryModifier<Model>,
        relationKeyPath: ChildrenKeyPath<RelatedModel, Model>) async throws -> Output
    where
        Input: AsyncResourceMutationModel,
        Model == Output.Model,
        Model == Input.Model {
            
            try Input.validate(content: req)
            let inputModel = try req.content.decode(Input.self)
            
            return try await req.db.transaction { db in
                                
                let (model, related) = try await resolver.find(req, db, relationKeyPath, queryModifier)
                
                let (processedModel, processedRelated) = try await middleware.handle(
                                            try await inputModel.mutate(model, req: req, database: db),
                                            relatedModel: related,
                                            req: req,
                                            database: db)

                try processedModel.attached(to: processedRelated, with: relationKeyPath)
                try await processedModel.save(on: db)
                
                return try Output(processedModel, req: req)

            }
        }
    
    func mutate<Input, Model, RelatedModel>(
        resolver: ParentResolver<Model, RelatedModel>,
        req: Request,
        using: Input.Type,
        willSave middleware: ControllerMiddleware<Model, RelatedModel> = .empty,
        queryModifier: QueryModifier<Model>,
        relationKeyPath: ChildrenKeyPath<Model, RelatedModel>) throws -> EventLoopFuture<Output>
    where
        Input: ResourceMutationModel,
        Model == Output.Model,
        Model == Input.Model {

        try Input.validate(content: req)
        let inputModel = try req.content.decode(Input.self)
        let keyPath = relationKeyPath
        return req.db.tryTransaction { db in
            
            try resolver
                .find(req, db, relationKeyPath, queryModifier)
                .flatMap { (model, related) in inputModel.mutate(model, req: req ,database: db).and(value: related) }
                .flatMap { (model, related ) in middleware.handle(model,
                                                                  relatedModel: related,
                                                                  req: req,
                                                                  database: db) }
                .flatMap { (model, related) in  model.save(on: db).transform(to: (model, related)) }
                .flatMapThrowing { (model, related) in (try model.attached(to: related, with: keyPath), related) }
                .flatMap { (model, related) in
                    [related.save(on: db), model.save(on: db)]
                        .flatten(on: db.context.eventLoop)
                        .transform(to: model) }
                .flatMapThrowing { try Output($0, req: req)}
        }
    }
    
    @available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
    func mutate<Input, Model, RelatedModel>(
        resolver: AsyncParentResolver<Model, RelatedModel>,
        req: Request,
        using: Input.Type,
        willSave middleware: AsyncControllerMiddleware<Model, RelatedModel> = .empty,
        queryModifier: QueryModifier<Model>,
        relationKeyPath: ChildrenKeyPath<Model, RelatedModel>) async throws -> Output
    where
        Input: AsyncResourceMutationModel,
        Model == Output.Model,
        Model == Input.Model {

            try Input.validate(content: req)
            let inputModel = try req.content.decode(Input.self)
            let keyPath = relationKeyPath
            return try await req.db.transaction { db in

                let (model, related) = try await resolver.find(req, db, relationKeyPath, queryModifier)
                
                let (processedModel, processedRelated) = try await middleware.handle(
                                            try await inputModel.mutate(model, req: req, database: db),
                                            relatedModel: related,
                                            req: req,
                                            database: db)

                try await processedModel.save(on: db)
                try processedModel.attached(to: processedRelated, with: keyPath)
                try await processedModel.save(on: db)
                try await processedRelated.save(on: db)

                return try Output(processedModel, req: req)

            }
            
        }
            
    func mutate<Input, Model, RelatedModel, Through>(
        resolver: SiblingsResolver<Model, RelatedModel, Through>,
        req: Request,
        using: Input.Type,
        willSave middleware: ControllerMiddleware<Model, RelatedModel> = .empty,
        queryModifier: QueryModifier<Model>,
        relationKeyPath: SiblingKeyPath<RelatedModel, Model, Through>) throws -> EventLoopFuture<Output>
    where
        Input: ResourceMutationModel,
        Model == Output.Model,
        Model == Input.Model {
        
        try Input.validate(content: req)
        let inputModel = try req.content.decode(Input.self)
        return req.db.tryTransaction { db in
            
            try resolver
                .find(req, db, relationKeyPath, queryModifier)
                .flatMap { (model, related) in inputModel.mutate(model, req: req ,database: db).and(value: related) }
                .flatMap { (model, related) in middleware.handle(model,
                                                                 relatedModel: related,
                                                                 req: req,
                                                                 database: db) }
                .flatMap { (model, related) in model.save(on: db).transform(to: (model, related)) }
                .flatMap { (model, related) in model.attached(to: related, with: relationKeyPath, on: db) }
                .flatMapThrowing { try Output($0, req: req) }
        }
    }
            
    @available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
    func mutate<Input, Model, RelatedModel, Through>(
        resolver: AsyncSiblingsResolver<Model, RelatedModel, Through>,
        req: Request,
        using: Input.Type,
        willSave middleware: AsyncControllerMiddleware<Model, RelatedModel> = .empty,
        queryModifier: QueryModifier<Model>,
        relationKeyPath: SiblingKeyPath<RelatedModel, Model, Through>) async throws -> Output
    where
        Input: AsyncResourceMutationModel,
        Model == Output.Model,
        Model == Input.Model {
        
            
            try Input.validate(content: req)
            let inputModel = try req.content.decode(Input.self)
            
            return try await req.db.transaction { db in
                
                let (model, related) = try await resolver.find(req, db, relationKeyPath, queryModifier)
                
                let (processedModel, processedRelated) = try await middleware.handle(
                                            try await inputModel.mutate(model, req: req, database: db),
                                            relatedModel: related,
                                            req: req,
                                            database: db)

                try await processedModel.save(on: db)
                try await processedModel.attached(to: processedRelated, with: relationKeyPath, on: db)

                return try Output(processedModel, req: req)
            }

        }
}
