//
//  File.swift
//  
//
//  Created by Alex Tran-Qui on 16/03/2022.
//

import Vapor
import Fluent

public extension AsyncRelationsController {
    @available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
    func deleteRelation<Model, RelatedModel>(
        resolver: AsyncChildResolver<Model, RelatedModel> = .byIdKeys,
        req: Request,
        willDetach middleware: AsyncControllerMiddleware<Model, RelatedModel> = .empty,
        queryModifier: QueryModifier<Model> = .empty,
        relationKeyPath: ChildrenKeyPath<RelatedModel, Model>) async throws -> Output
    where
        Model == Output.Model {
        
            return try await req.db.transaction { db in
                let (model, related) = try await resolver.find(req, db, relationKeyPath, queryModifier)
                let (processedModel, processedRelated) = try await middleware.handle(model,
                                            relatedModel: related,
                                            req: req,
                                            database: db)
                try processedModel.detached(from: processedRelated, with: relationKeyPath)
                try await processedModel.save(on: db)
                
                return try await Output(processedModel, req: req)
            }
        }
    
    @available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
    func deleteRelation<Model, RelatedModel>(
        resolver: AsyncParentResolver<Model, RelatedModel> = .byIdKeys,
        req: Request,
        willDetach middleware: AsyncControllerMiddleware<Model, RelatedModel> = .empty,
        queryModifier: QueryModifier<Model> = .empty,
        relationKeyPath: ChildrenKeyPath<Model, RelatedModel>) async throws -> Output
    where
        Model == Output.Model {
        
            return try await req.db.transaction { db in
                let (model, related) = try await resolver.find(req, db, relationKeyPath, queryModifier)
                let (processedModel, processedRelated) = try await middleware.handle(model,
                                            relatedModel: related,
                                            req: req,
                                            database: db)
                try processedModel.detached(from: processedRelated, with: relationKeyPath)
                try await processedRelated.save(on: db)
                
                return try await Output(processedModel, req: req)
            }
        }

    @available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
    func deleteRelation<Model, RelatedModel, Through>(
        resolver: AsyncSiblingsResolver<Model, RelatedModel, Through> = .byIdKeys,
        req: Request,
        willDetach middleware: AsyncControllerMiddleware<Model, RelatedModel> = .empty,
        queryModifier: QueryModifier<Model> = .empty,
        relationKeyPath: SiblingKeyPath<RelatedModel, Model, Through>) async throws -> Output
    where
        Model == Output.Model {
        
            return try await req.db.transaction { db in
                let (model, related) = try await resolver.find(req, db, relationKeyPath, queryModifier)
                let (processedModel, processedRelated) = try await middleware.handle(model,
                                            relatedModel: related,
                                            req: req,
                                            database: db)
                try await processedModel.detached(from: processedRelated, with: relationKeyPath, on: db)
                
                return try await Output(processedModel, req: req)
            }
        }
}

