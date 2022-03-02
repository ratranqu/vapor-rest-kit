//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 14.08.2021.
//

import Vapor
import Fluent

public extension ResourceController {
    func getCursorPage<Model>(
        req: Request,
        queryModifier: QueryModifier<Model> = .empty,
        config: CursorPaginationConfig = .defaultConfig) throws -> EventLoopFuture<CursorPage<Output>>
    where
        Output.Model == Model {
        
        try Model
            .query(on: req.db)
            .with(queryModifier, for: req)
            .paginateWithCursor(for: req, config: config)
            .flatMapThrowing { collection in try collection.map { try Output($0, req: req) } }
    }
    
    func getCursorPage<Model>(
        req: Request,
        queryModifier: QueryModifier<Model> = .empty,
        config: CursorPaginationConfig = .defaultConfig) async throws -> CursorPage<Output>
    where
        Output.Model == Model {
        
            try await getCursorPage(req: req, queryModifier: queryModifier, config: config).get()
    }

}

public extension RelatedResourceController {
    func getCursorPage<Model, RelatedModel>(
        resolver: Resolver<RelatedModel> = .byIdKeys,
        req: Request,
        queryModifier: QueryModifier<Model> = .empty,
        relationKeyPath: ChildrenKeyPath<RelatedModel, Model>,
        config: CursorPaginationConfig = .defaultConfig) throws -> EventLoopFuture<CursorPage<Output>>
    where
        Model == Output.Model {
        
        try resolver
            .find(req, req.db)
            .flatMapThrowing { related in related.queryRelated(keyPath: relationKeyPath, on: req.db) }
            .flatMapThrowing { query in try query.with(queryModifier, for: req) }
            .flatMap { query in query.paginateWithCursor(for: req, config: config) }
            .flatMapThrowing { collection in try collection.map { try Output($0, req: req) } }
    }
    
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
            return try collection.map { try Output($0, req: req) }
        }
    
    func getCursorPage<Model, RelatedModel>(
        resolver: Resolver<RelatedModel> = .byIdKeys,
        req: Request,
        queryModifier: QueryModifier<Model> = .empty,
        relationKeyPath: ChildrenKeyPath<Model, RelatedModel>,
        config: CursorPaginationConfig = .defaultConfig) throws -> EventLoopFuture<CursorPage<Output>>
    where
        Model == Output.Model {
        
        try resolver
            .find(req, req.db)
            .flatMapThrowing { related in try related.queryRelated(keyPath: relationKeyPath, on: req.db) }
            .flatMapThrowing { query in try query.with(queryModifier, for: req) }
            .flatMap { query in query.paginateWithCursor(for: req, config: config) }
            .flatMapThrowing { collection in try collection.map { try Output($0, req: req) } }
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
            return try collection.map { try Output($0, req: req) }

            }
    
    func getCursorPage<Model, RelatedModel, Through>(
        resolver: Resolver<RelatedModel> = .byIdKeys,
        req: Request,
        queryModifier: QueryModifier<Model> = .empty,
        relationKeyPath: SiblingKeyPath<RelatedModel, Model, Through>,
        config: CursorPaginationConfig = .defaultConfig) throws -> EventLoopFuture<CursorPage<Output>>
    where
        Model == Output.Model {
        
        try resolver
            .find(req, req.db)
            .flatMapThrowing { related in related.queryRelated(keyPath: relationKeyPath, on: req.db) }
            .flatMapThrowing { query in try query.with(queryModifier, for: req) }
            .flatMap { query in query.paginateWithCursor(for: req, config: config) }
            .flatMapThrowing { collection in try collection.map { try Output($0, req: req) }
            
            }
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
            return try collection.map { try Output($0, req: req) }

        }
}
