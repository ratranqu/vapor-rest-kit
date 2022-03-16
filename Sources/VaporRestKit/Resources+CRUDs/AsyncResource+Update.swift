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
    func update<Input, Model>(
        req: Request,
        using: Input.Type,
        queryModifier: QueryModifier<Model> = .empty) async throws -> Output
    where
        Input: AsyncResourceUpdateModel,
        Output.Model == Model,
        Input.Model == Output.Model {
        
        try await mutate(req: req, using: using, queryModifier: queryModifier)
    }
}

public extension AsyncRelatedResourceController {
    
    @available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
    func update<Input, Model, RelatedModel>(
        resolver: AsyncChildResolver<Model, RelatedModel> = .byIdKeys,
        req: Request,
        using: Input.Type,
        willSave middleware: AsyncControllerMiddleware<Model, RelatedModel> = .empty,
        queryModifier: QueryModifier<Model> = .empty,
        relationKeyPath: ChildrenKeyPath<RelatedModel, Model>) async throws -> Output
    where
        Input: AsyncResourceUpdateModel,
        Model == Output.Model,
        Input.Model == Output.Model  {
        
        try await mutate(resolver: resolver,
                   req: req,
                   using: using,
                   willSave: middleware,
                   queryModifier: queryModifier,
                   relationKeyPath: relationKeyPath)
    }

    @available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
    func update<Input, Model, RelatedModel>(
        resolver: AsyncParentResolver<Model, RelatedModel> = .byIdKeys,
        req: Request,
        using: Input.Type,
        willSave middleware: AsyncControllerMiddleware<Model, RelatedModel> = .empty,
        queryModifier: QueryModifier<Model> = .empty,
        relationKeyPath: ChildrenKeyPath<Model, RelatedModel>) async throws -> Output
    where
        Input: AsyncResourceUpdateModel,
        Model == Output.Model,
        Input.Model == Output.Model {
        
            try await mutate(resolver: resolver,
                   req: req,
                   using: using,
                   willSave: middleware,
                   queryModifier: queryModifier,
                   relationKeyPath: relationKeyPath)
    }
    
    @available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
    func update<Input, Model, RelatedModel, Through>(
        resolver: AsyncSiblingsResolver<Model, RelatedModel, Through> = .byIdKeys,
        req: Request,
        using: Input.Type,
        willSave middleware: AsyncControllerMiddleware<Model, RelatedModel> = .empty,
        queryModifier: QueryModifier<Model> = .empty,
        relationKeyPath: SiblingKeyPath<RelatedModel, Model, Through>) async throws -> Output
    where
        Input: AsyncResourceUpdateModel,
        Model == Output.Model,
        Input.Model == Output.Model {
        
            try await mutate(resolver: resolver,
                   req: req,
                   using: using,
                   willSave: middleware,
                   queryModifier: queryModifier,
                   relationKeyPath: relationKeyPath)
    }
}
