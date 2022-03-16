//
//  File.swift
//  
//
//  Created by Alex Tran-Qui on 16/03/2022.
//

import Vapor
import Fluent
import NIOPosix

public extension AsyncResourceController {
    @available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
    func read<Model>(req: Request,
                      queryModifier: QueryModifier<Model> = .empty) async throws -> Output
    where
        Output.Model == Model {
            let model = try await Model.findByIdKey(req, database: req.db, queryModifier: queryModifier)
            return try await Output(model, req: req)
    }
}

public extension AsyncRelatedResourceController {
    @available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
    func read<Model, RelatedModel>(
        resolver: AsyncChildResolver<Model, RelatedModel> = .byIdKeys,
        req: Request,
        queryModifier: QueryModifier<Model> = .empty,
        relationKeyPath: ChildrenKeyPath<RelatedModel, Model>) async throws -> Output
        where
            Model == Output.Model {

                let (model, _) = try await resolver.find(req, req.db, relationKeyPath, queryModifier)
                return try await Output(model, req: req)
        }

    @available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
    func read<Model, RelatedModel>(
        resolver: AsyncParentResolver<Model, RelatedModel> = .byIdKeys,
        req: Request,
        queryModifier: QueryModifier<Model> = .empty,
        relationKeyPath: ChildrenKeyPath<Model, RelatedModel>)  async throws -> Output
    where
        Model == Output.Model {

            let (model, _) = try await resolver.find(req, req.db, relationKeyPath, queryModifier)
            return try await Output(model, req: req)

    }
    
    @available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
    func read<Model, RelatedModel, Through>(
        resolver: AsyncSiblingsResolver<Model, RelatedModel, Through> = .byIdKeys,
        req: Request,
        queryModifier: QueryModifier<Model> = .empty,
        relationKeyPath: SiblingKeyPath<RelatedModel, Model, Through>)  async throws -> Output
    where
        Model == Output.Model {

            let (model, _) = try await resolver.find(req, req.db, relationKeyPath, queryModifier)
            return try await Output(model, req: req)
    }
}

