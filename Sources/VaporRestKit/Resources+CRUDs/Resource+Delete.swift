//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 08.08.2021.
//

import Vapor
import Fluent

public extension ResourceController {
    func delete<Model>(
        req: Request,
        using deleter: Deleter<Model> = .defaultDeleter(),
        queryModifier: QueryModifier<Model> = .empty) throws -> EventLoopFuture<Output>
    where
        Output.Model == Model {

        req.db.tryTransaction { db in
            try Model
                .findByIdKey(req, database: db, queryModifier: queryModifier)
                .flatMap { model in
                    deleter
                        .performDelete(model, req: req, database: db)
                        .transform(to: model) }
                .flatMapThrowing { try Output($0, req: req) }
        }
    }
    
    @available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
    func delete<Model>(
        req: Request,
        using deleter: AsyncDeleter<Model> = .defaultDeleter(),
        queryModifier: QueryModifier<Model> = .empty) async throws -> Output
    where
        Output.Model == Model {

            try await req.db.transaction { db in
                let model = try await Model
                    .findByIdKey(req, database: db, queryModifier: queryModifier)
 
                return try Output(try await deleter.performDelete(model, req: req, database: db), req: req)
            }
        }
}

public extension RelatedResourceController {

    func delete<Model, RelatedModel>(
        resolver: ChildResolver<Model, RelatedModel> = .byIdKeys,
        req: Request,
        using deleter: Deleter<Model> = .defaultDeleter(),
        willDetach middleware: ControllerMiddleware<Model, RelatedModel> = .empty,
        queryModifier: QueryModifier<Model> = .empty,
        relationKeyPath: ChildrenKeyPath<RelatedModel, Model>) throws -> EventLoopFuture<Output>
    where
        Model == Output.Model {

        req.db.tryTransaction { db in

            try resolver
                .find(req, db, relationKeyPath, queryModifier)
                .flatMap { (model, related) in middleware.handle(model,
                                                                        relatedModel: related,
                                                                        req: req,
                                                                        database: db) }
                .flatMap { (model, related) in
                    deleter
                        .performDelete(model, req: req, database: db)
                        .transform(to: model) }
                .flatMapThrowing { try Output($0, req: req) }
        }
    }

    @available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
    func delete<Model, RelatedModel>(
        resolver: AsyncChildResolver<Model, RelatedModel> = .byIdKeys,
        req: Request,
        using deleter: AsyncDeleter<Model> = .defaultDeleter(),
        willDetach middleware: AsyncControllerMiddleware<Model, RelatedModel> = .empty,
        queryModifier: QueryModifier<Model> = .empty,
        relationKeyPath: ChildrenKeyPath<RelatedModel, Model>) async throws -> Output
    where
        Model == Output.Model {

            try await req.db.transaction { db in
                let (model, related) = try await resolver.find(req, db, relationKeyPath, queryModifier)
                let (processedModel, _) = try await middleware.handle(model,
                                            relatedModel: related,
                                            req: req,
                                            database: db)

                return try Output(try await deleter.performDelete(processedModel, req: req, database: db), req: req)

            }
        }

    func delete<Model, RelatedModel>(
        resolver: ParentResolver<Model, RelatedModel> = .byIdKeys,
        req: Request,
        using deleter: Deleter<Model> = .defaultDeleter(),
        willDetach middleware: ControllerMiddleware<Model, RelatedModel> = .empty,
        queryModifier: QueryModifier<Model> = .empty,
        relationKeyPath: ChildrenKeyPath<Model, RelatedModel>) throws -> EventLoopFuture<Output>
    where
        Model == Output.Model {

        req.db.tryTransaction { db in

            try resolver
                .find(req, db, relationKeyPath, queryModifier)
                .flatMap { (model, related) in middleware.handle(model,
                                                                        relatedModel: related,
                                                                        req: req,
                                                                        database: db) }
                .flatMapThrowing { (model, related) in
                    try model.detached(from: related, with: relationKeyPath)
                    return related.save(on: db).transform(to: model) }
                .flatMap { $0 }
                .flatMap { model in
                    deleter
                        .performDelete(model, req: req, database: db)
                        .transform(to: model) }
                .flatMapThrowing { try Output($0, req: req) }
        }
    }
    
    @available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
    func delete<Model, RelatedModel>(
        resolver: AsyncParentResolver<Model, RelatedModel> = .byIdKeys,
        req: Request,
        using deleter: AsyncDeleter<Model> = .defaultDeleter(),
        willDetach middleware: AsyncControllerMiddleware<Model, RelatedModel> = .empty,
        queryModifier: QueryModifier<Model> = .empty,
        relationKeyPath: ChildrenKeyPath<Model, RelatedModel>) async throws -> Output
    where
        Model == Output.Model {

            try await req.db.transaction { db in
                let (model, related) = try await resolver.find(req, db, relationKeyPath, queryModifier)
                let (processedModel, processedRelated) = try await middleware.handle(model,
                                            relatedModel: related,
                                            req: req,
                                            database: db)
                try processedModel.detached(from: processedRelated, with: relationKeyPath)
                try await processedRelated.save(on: db)
                
                return try Output(try await deleter.performDelete(processedModel, req: req, database: db), req: req)
            }
        }

    func delete<Model, RelatedModel, Through>(
        resolver: SiblingsResolver<Model, RelatedModel, Through> = .byIdKeys,
        req: Request,
        using deleter: Deleter<Model> = .defaultDeleter(),
        willDetach middleware: ControllerMiddleware<Model, RelatedModel> = .empty,
        queryModifier: QueryModifier<Model> = .empty,
        relationKeyPath: SiblingKeyPath<RelatedModel, Model, Through>) throws -> EventLoopFuture<Output>
    where

        Model == Output.Model {

        req.db.tryTransaction { db in

            try resolver
                .find(req, db, relationKeyPath, queryModifier)
                .flatMap { (model, related) in middleware.handle(model,
                                                                        relatedModel: related,
                                                                        req: req,
                                                                        database: db) }
                .flatMap { (model, related) in model.detached(from: related, with: relationKeyPath, on: db) }
                .flatMap { model in
                    deleter
                        .performDelete(model, req: req, database: db)
                        .transform(to: model) }
                .flatMapThrowing { try Output($0, req: req) }
        }
    }
    
    @available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
    func delete<Model, RelatedModel, Through>(
        resolver: AsyncSiblingsResolver<Model, RelatedModel, Through> = .byIdKeys,
        req: Request,
        using deleter: AsyncDeleter<Model> = .defaultDeleter(),
        willDetach middleware: AsyncControllerMiddleware<Model, RelatedModel> = .empty,
        queryModifier: QueryModifier<Model> = .empty,
        relationKeyPath: SiblingKeyPath<RelatedModel, Model, Through>) async throws -> Output
    where

        Model == Output.Model {

            try await req.db.transaction { db in                
                let (model, related) = try await resolver.find(req, db, relationKeyPath, queryModifier)
                let (processedModel, processedRelated) = try await middleware.handle(model,
                                            relatedModel: related,
                                            req: req,
                                            database: db)
                try await processedModel.detached(from: processedRelated, with: relationKeyPath, on: db)
                
                return try Output(try await deleter.performDelete(processedModel, req: req, database: db), req: req)

            }
        }
}
