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
    func getCursorPage<Model>(
        req: Request,
        queryModifier: QueryModifier<Model> = .empty,
        config: CursorPaginationConfig = .defaultConfig) async throws -> CursorPage<Output>
    where
        Output.Model == Model {
            let collection = try await Model
                .query(on: req.db)
                .with(queryModifier, for: req)
                .paginateWithCursor(for: req, config: config)
            return try await collection.asyncMap { try await Output($0, req: req) }
    }

}

public extension AsyncRelatedResourceController {
    @available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
    func getCursorPage<Model, RelatedModel>(
        resolver: AsyncResolver<RelatedModel> = .byIdKeys,
        req: Request,
        queryModifier: QueryModifier<Model> = .empty,
        relationKeyPath: ChildrenKeyPath<RelatedModel, Model>,
        config: CursorPaginationConfig = .defaultConfig) async throws -> CursorPage<Output>
    where
        Model == Output.Model {
        
            let related = try await resolver.find(req, req.db)
            let query = related.queryRelated(keyPath: relationKeyPath, on: req.db)
            let result = try query.with(queryModifier, for: req)
            let collection = try await result.paginateWithCursor(for: req, config: config)
            return try await collection.asyncMap { try await Output($0, req: req) }
        }
    
            @available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
            func getCursorPage<Model, RelatedModel>(
        resolver: AsyncResolver<RelatedModel> = .byIdKeys,
        req: Request,
        queryModifier: QueryModifier<Model> = .empty,
        relationKeyPath: ChildrenKeyPath<Model, RelatedModel>,
        config: CursorPaginationConfig = .defaultConfig) async throws -> CursorPage<Output>
    where
        Model == Output.Model {
        
            let related = try await resolver.find(req, req.db)
            let query = try related.queryRelated(keyPath: relationKeyPath, on: req.db)
            let result = try query.with(queryModifier, for: req)
            let collection = try await result.paginateWithCursor(for: req, config: config)
            return try await collection.asyncMap { try await Output($0, req: req) }

            }
       
        @available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
        func getCursorPage<Model, RelatedModel, Through>(
        resolver: AsyncResolver<RelatedModel> = .byIdKeys,
        req: Request,
        queryModifier: QueryModifier<Model> = .empty,
        relationKeyPath: SiblingKeyPath<RelatedModel, Model, Through>,
        config: CursorPaginationConfig = .defaultConfig) async throws -> CursorPage<Output>
    where
        Model == Output.Model {
        
            let related = try await resolver.find(req, req.db)
            let query = related.queryRelated(keyPath: relationKeyPath, on: req.db)
            let result = try query.with(queryModifier, for: req)
            let collection = try await result.paginateWithCursor(for: req, config: config)
            return try await collection.asyncMap { try await Output($0, req: req) }

        }
}
