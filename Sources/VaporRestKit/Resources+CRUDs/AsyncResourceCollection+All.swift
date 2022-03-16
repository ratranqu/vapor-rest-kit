//
//  File.swift
//  
//
//  Created by Alex Tran-Qui on 16/03/2022.
//

import Foundation

import Vapor
import Fluent

public extension AsyncResourceController {
    @available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
    func getAll<Model>(req: Request,
                        queryModifier: QueryModifier<Model> = .empty) async throws -> [Output]
    where
        Output.Model == Model {
            let collection = try await Model
                .query(on: req.db)
                .with(queryModifier, for: req)
                .all()
            return try await collection.asyncMap { try await Output($0, req: req) }
    }
}

public extension AsyncRelatedResourceController {
    @available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
    func getAll<Model, RelatedModel>(
        resolver: AsyncResolver<RelatedModel> = .byIdKeys,
        req: Request,
        queryModifier: QueryModifier<Model> = .empty,
        relationKeyPath: ChildrenKeyPath<RelatedModel, Model>) async throws -> [Output]
    where
        Model == Output.Model {
        
            let related = try await resolver.find(req, req.db)
            let query = related.queryRelated(keyPath: relationKeyPath, on: req.db)
            let result = try query.with(queryModifier, for: req)
            let collection = try await result.all()
            return try await collection.asyncMap { try await Output($0, req: req) }

        }
    
    @available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
    func getAll<Model, RelatedModel>(
        resolver: AsyncResolver<RelatedModel> = .byIdKeys,
        req: Request,
        queryModifier: QueryModifier<Model> = .empty,
        relationKeyPath: ChildrenKeyPath<Model, RelatedModel>) async throws -> [Output]
    where
        Model == Output.Model {
        
            let related = try await resolver.find(req, req.db)
            let query = try related.queryRelated(keyPath: relationKeyPath, on: req.db)
            let result = try query.with(queryModifier, for: req)
            let collection = try await result.all()
            return try await collection.asyncMap { try await Output($0, req: req) }
}
    
    @available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
    func getAll<Model, RelatedModel, Through>(
        resolver: AsyncResolver<RelatedModel> = .byIdKeys,
        req: Request,
        queryModifier: QueryModifier<Model> = .empty,
        relationKeyPath: SiblingKeyPath<RelatedModel, Model, Through>) async throws -> [Output]
    where
        Model == Output.Model {
        
            let related = try await resolver.find(req, req.db)
            let query = related.queryRelated(keyPath: relationKeyPath, on: req.db)
            let result = try query.with(queryModifier, for: req)
            let collection = try await result.all()
            return try await collection.asyncMap { try await Output($0, req: req) }
    }
}
