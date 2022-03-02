//
//  File.swift
//  
//
//  Created by Alex Tran-Qui on 02/03/2022.
//

import Vapor
import Fluent

public extension AsyncResourceController {
    func getPage<Model>(
        req: Request,
        queryModifier: QueryModifier<Model> = .empty) throws -> EventLoopFuture<Page<Output>>
    where
        Output.Model == Model {
        
        try Model
            .query(on: req.db)
            .with(queryModifier, for: req)
            .paginate(for: req)
            .flatMapThrowing { collection in try collection.map { try Output($0, req: req) } }
    }
    
    @available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
    func getPage<Model>(
        req: Request,
        queryModifier: QueryModifier<Model> = .empty) async throws -> Page<Output>
    where
        Output.Model == Model {
        
            try await getPage(req: req, queryModifier: queryModifier).get()
    }
}

public extension AsyncResourceController {
    
    @available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
    func getPage<Model, RelatedModel>(
        resolver: AsyncResolver<RelatedModel> = .byIdKeys,
        req: Request,
        queryModifier: QueryModifier<Model> = .empty,
        relationKeyPath: ChildrenKeyPath<RelatedModel, Model>) async throws -> Page<Output>
    where
        Model == Output.Model {
        
            let related = try await resolver.find(req, req.db)
            let query = related.queryRelated(keyPath: relationKeyPath, on: req.db)
            let result = try query.with(queryModifier, for: req)
            let collection = try await result.paginate(for: req)
            return try collection.map { try Output($0, req: req) }
    }
    
    @available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
    func getPage<Model, RelatedModel>(
        resolver: AsyncResolver<RelatedModel> = .byIdKeys,
        req: Request,
        queryModifier: QueryModifier<Model> = .empty,
        relationKeyPath: ChildrenKeyPath<Model, RelatedModel>) async throws -> Page<Output>
    where
        Model == Output.Model {
        
            let related = try await resolver.find(req, req.db)
            let query = try related.queryRelated(keyPath: relationKeyPath, on: req.db)
            let result = try query.with(queryModifier, for: req)
            let collection = try await result.paginate(for: req)
            return try collection.map { try Output($0, req: req) }
        }
    

    @available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
    func getPage<Model, RelatedModel, Through>(
        resolver: AsyncResolver<RelatedModel> = .byIdKeys,
        req: Request,
        queryModifier: QueryModifier<Model> = .empty,
        relationKeyPath: SiblingKeyPath<RelatedModel, Model, Through>) async throws -> Page<Output>
    where
        Model == Output.Model {
        
            let related = try await resolver.find(req, req.db)
            let query = related.queryRelated(keyPath: relationKeyPath, on: req.db)
            let result = try query.with(queryModifier, for: req)
            let collection = try await result.paginate(for: req)
            return try collection.map { try Output($0, req: req)
            }
        }
}
