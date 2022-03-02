//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 18.07.2021.
//

import Vapor
import Fluent

public extension RelationsController {
    
    func createRelation<Model, RelatedModel>(
        resolver: Resolver<RelatedModel> = .byIdKeys,
        req: Request,
        willAttach middleware: ControllerMiddleware<Model, RelatedModel> = .empty,
        queryModifier: QueryModifier<Model> = .empty,
        relationKeyPath: ChildrenKeyPath<RelatedModel, Model>) throws -> EventLoopFuture<Output>
    where
        Model == Output.Model {
        
        req.db.tryTransaction { db in
            
            try resolver
                .find(req, db)
                .and(Model.findByIdKey(req, database: db, queryModifier: queryModifier))
                .flatMap { (related, model) in middleware.handle(model,
                                                                        relatedModel: related,
                                                                        req: req,
                                                                        database: db) }
                .flatMapThrowing { (model, related) in
                    try model.attached(to: related, with: relationKeyPath) }
                .flatMap { model in model.save(on: db).transform(to: model) }
                .flatMapThrowing { try Output($0, req: req) }
        }
    }
    
    @available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
    func createRelation<Model, RelatedModel>(
        resolver: AsyncResolver<RelatedModel> = .byIdKeys,
        req: Request,
        willAttach middleware: AsyncControllerMiddleware<Model, RelatedModel> = .empty,
        queryModifier: QueryModifier<Model> = .empty,
        relationKeyPath: ChildrenKeyPath<RelatedModel, Model>) async throws -> Output
    where
        Model == Output.Model {
        
            return try await req.db.transaction { db in
                let (model, related) = try await middleware.handle(try await Model.findByIdKey(req, database: db, queryModifier: queryModifier),
                                            relatedModel: try await resolver.find(req, db),
                                            req: req,
                                            database: db)
                try model.attached(to: related, with: relationKeyPath)
                try await model.save(on: db)
                
                return try Output(model, req: req)
            }
        }
    
    func createRelation<Model, RelatedModel>(
        resolver: Resolver<RelatedModel> = .byIdKeys,
        req: Request,
        willAttach middleware: ControllerMiddleware<Model, RelatedModel> = .empty,
        queryModifier: QueryModifier<Model> = .empty,
        relationKeyPath: ChildrenKeyPath<Model, RelatedModel>) throws -> EventLoopFuture<Output>
    where
        Model == Output.Model {
        
        req.db.tryTransaction { db in
            
            try resolver
                .find(req, db)
                .and(Model.findByIdKey(req, database: db, queryModifier: queryModifier))
                .flatMap { (related, model) in middleware.handle(model,
                                                                        relatedModel: related,
                                                                        req: req,
                                                                        database: db) }
                .flatMapThrowing { (model, related) in
                    try model.attached(to: related, with: relationKeyPath)
                    return related.save(on: db).transform(to: model) }
                .flatMap { $0 }
                .flatMapThrowing { try Output($0, req: req) }
        }
    }
    
    @available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
    func createRelation<Model, RelatedModel>(
        resolver: AsyncResolver<RelatedModel> = .byIdKeys,
        req: Request,
        willAttach middleware: AsyncControllerMiddleware<Model, RelatedModel> = .empty,
        queryModifier: QueryModifier<Model> = .empty,
        relationKeyPath: ChildrenKeyPath<Model, RelatedModel>) async throws -> Output
    where
        Model == Output.Model {
            
            return try await req.db.transaction { db in
                let (model, related) = try await middleware.handle(try await Model.findByIdKey(req, database: db, queryModifier: queryModifier),
                                            relatedModel: try await resolver.find(req, db),
                                            req: req,
                                            database: db)
                try model.attached(to: related, with: relationKeyPath)
                try await related.save(on: db)
                return try Output(model, req: req)
            }
        }
    
    func createRelation<Model, RelatedModel, Through>(
        resolver: Resolver<RelatedModel> = .byIdKeys,
        req: Request,
        willAttach middleware: ControllerMiddleware<Model, RelatedModel> = .empty,
        queryModifier: QueryModifier<Model> = .empty,
        relationKeyPath: SiblingKeyPath<RelatedModel, Model, Through>) throws -> EventLoopFuture<Output>
    where
        Model == Output.Model {
        
        req.db.tryTransaction { db in
            
            try resolver
                .find(req, db)
                .and(Model.findByIdKey(req, database: db, queryModifier: queryModifier))
                .flatMap { (related, model) in middleware.handle(model,
                                                                        relatedModel: related,
                                                                        req: req,
                                                                        database: db) }
                .flatMap { (model, related) in
                    model.attached(to: related, with: relationKeyPath, on: db) }
                .flatMapThrowing { try Output($0, req: req)}
        }
    }
    
    @available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
    func createRelation<Model, RelatedModel, Through>(
        resolver: AsyncResolver<RelatedModel> = .byIdKeys,
        req: Request,
        willAttach middleware: AsyncControllerMiddleware<Model, RelatedModel> = .empty,
        queryModifier: QueryModifier<Model> = .empty,
        relationKeyPath: SiblingKeyPath<RelatedModel, Model, Through>) async throws -> Output
    where
        Model == Output.Model {
        
            return try await req.db.transaction { db in
                let (model, related) = try await middleware.handle(try await Model.findByIdKey(req, database: db, queryModifier: queryModifier),
                                            relatedModel: try await resolver.find(req, db),
                                            req: req,
                                            database: db)
                try await model.attached(to: related, with: relationKeyPath, on: db)

                return try Output(model, req: req)
            }
    }
}
