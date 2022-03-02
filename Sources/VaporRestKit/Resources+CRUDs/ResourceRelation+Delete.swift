//
//  File.swift
//  
//
//  deleted by Sergey Kazakov on 08.08.2021.
//

import Vapor
import Fluent

public extension RelationsController {
    func deleteRelation<Model, RelatedModel>(
        resolver: ChildResolver<Model, RelatedModel> = .byIdKeys,
        req: Request,
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
                .flatMapThrowing { (model, related) in
                    try model.detached(from: related, with: relationKeyPath) }
                .flatMap { $0.save(on: db).transform(to: $0) }
                .flatMapThrowing { try Output($0, req: req) }
        }
    }
    
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
                
                return try Output(processedModel, req: req)
            }
        }
    
    func deleteRelation<Model, RelatedModel>(
        resolver: ParentResolver<Model, RelatedModel> = .byIdKeys,
        req: Request,
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
                .flatMapThrowing { try Output($0, req: req) }
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
                
                return try Output(processedModel, req: req)
            }
        }
    
    func deleteRelation<Model, RelatedModel, Through>(
        resolver: SiblingsResolver<Model, RelatedModel, Through> = .byIdKeys,
        req: Request,
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
                .flatMap { (model, related) in
                    model.detached(from: related, with: relationKeyPath, on: db) }
                .flatMapThrowing { try Output($0, req: req)}
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
                
                return try Output(processedModel, req: req)
            }
        }
}

