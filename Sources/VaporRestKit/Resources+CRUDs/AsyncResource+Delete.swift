//
//  File.swift
//  
//
//  Created by Alex Tran-Qui on 16/03/2022.
//

import Vapor
import Fluent

public extension AsyncResourceController {
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
 
                return try await Output(try await deleter.performDelete(model, req: req, database: db), req: req)
            }
        }
}

public extension AsyncRelatedResourceController {
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

                return try await Output(try await deleter.performDelete(processedModel, req: req, database: db), req: req)

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
                
                return try await Output(try await deleter.performDelete(processedModel, req: req, database: db), req: req)
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
                
                return try await Output(try await deleter.performDelete(processedModel, req: req, database: db), req: req)

            }
        }
}
