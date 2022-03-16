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
                
                return try await Output(model, req: req)
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
                return try await Output(model, req: req)
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

                return try await Output(model, req: req)
            }
    }
}
