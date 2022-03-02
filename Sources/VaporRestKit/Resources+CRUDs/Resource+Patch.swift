//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 07.08.2021.
//

import Vapor
import Fluent

public extension ResourceController {
    func patch<Input, Model>(
        req: Request,
        using: Input.Type,
        queryModifier: QueryModifier<Model> = .empty) throws -> EventLoopFuture<Output>
    where
        Input: ResourcePatchModel,
        Output.Model == Model,
        Input.Model == Output.Model {
        
        try mutate(req: req, using: using, queryModifier: queryModifier)
    }
    
    @available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
    func patch<Input, Model>(
        req: Request,
        using: Input.Type,
        queryModifier: QueryModifier<Model> = .empty) async throws -> Output
    where
        Input: ResourcePatchModel,
        Output.Model == Model,
        Input.Model == Output.Model {
        
        try await mutate(req: req, using: using, queryModifier: queryModifier)
    }
}

public extension RelatedResourceController {
    
    func patch<Input, Model, RelatedModel>(
        resolver: ChildResolver<Model, RelatedModel> = .byIdKeys,
        req: Request,
        using: Input.Type,
        willSave middleware: ControllerMiddleware<Model, RelatedModel> = .empty,
        queryModifier: QueryModifier<Model> = .empty,
        relationKeyPath: ChildrenKeyPath<RelatedModel, Model>) throws -> EventLoopFuture<Output>
    where
        Input: ResourcePatchModel,
        Model == Output.Model,
        Input.Model == Output.Model {
        
        try mutate(resolver: resolver,
                   req: req,
                   using: using,
                   willSave: middleware,
                   queryModifier: queryModifier,
                   relationKeyPath: relationKeyPath)
    }
    
    @available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
    func patch<Input, Model, RelatedModel>(
        resolver: AsyncChildResolver<Model, RelatedModel> = .byIdKeys,
        req: Request,
        using: Input.Type,
        willSave middleware: AsyncControllerMiddleware<Model, RelatedModel> = .empty,
        queryModifier: QueryModifier<Model> = .empty,
        relationKeyPath: ChildrenKeyPath<RelatedModel, Model>) async throws -> Output
    where
        Input: ResourcePatchModel,
        Model == Output.Model,
        Input.Model == Output.Model {
        
        try await mutate(resolver: resolver,
                   req: req,
                   using: using,
                   willSave: middleware,
                   queryModifier: queryModifier,
                   relationKeyPath: relationKeyPath)
    }
    
    func patch<Input, Model, RelatedModel>(
        resolver: ParentResolver<Model, RelatedModel> = .byIdKeys,
        req: Request,
        using: Input.Type,
        willSave middleware: ControllerMiddleware<Model, RelatedModel> = .empty,
        queryModifier: QueryModifier<Model> = .empty,
        relationKeyPath: ChildrenKeyPath<Model, RelatedModel>) throws -> EventLoopFuture<Output>
    where
        Input: ResourcePatchModel,
        Model == Output.Model,
        Input.Model == Output.Model {
        
        try mutate(resolver: resolver,
                   req: req,
                   using: using,
                   willSave: middleware,
                   queryModifier: queryModifier,
                   relationKeyPath: relationKeyPath)
    }
    
    @available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
    func patch<Input, Model, RelatedModel>(
        resolver: AsyncParentResolver<Model, RelatedModel> = .byIdKeys,
        req: Request,
        using: Input.Type,
        willSave middleware: AsyncControllerMiddleware<Model, RelatedModel> = .empty,
        queryModifier: QueryModifier<Model> = .empty,
        relationKeyPath: ChildrenKeyPath<Model, RelatedModel>) async throws -> Output
    where
        Input: ResourcePatchModel,
        Model == Output.Model,
        Input.Model == Output.Model {
        
        try await mutate(resolver: resolver,
                   req: req,
                   using: using,
                   willSave: middleware,
                   queryModifier: queryModifier,
                   relationKeyPath: relationKeyPath)
    }
    
    func patch<Input, Model, RelatedModel, Through>(
        resolver: SiblingsResolver<Model, RelatedModel, Through> = .byIdKeys,
        req: Request,
        using: Input.Type,
        willSave middleware: ControllerMiddleware<Model, RelatedModel> = .empty,
        queryModifier: QueryModifier<Model> = .empty,
        relationKeyPath: SiblingKeyPath<RelatedModel, Model, Through>) throws -> EventLoopFuture<Output>
    where
        Input: ResourcePatchModel,
        Model == Output.Model,
        Input.Model == Output.Model {
        
        try mutate(resolver: resolver,
                   req: req,
                   using: using,
                   willSave: middleware,
                   queryModifier: queryModifier,
                   relationKeyPath: relationKeyPath)
    }
    
    @available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
    func patch<Input, Model, RelatedModel, Through>(
        resolver: AsyncSiblingsResolver<Model, RelatedModel, Through> = .byIdKeys,
        req: Request,
        using: Input.Type,
        willSave middleware: AsyncControllerMiddleware<Model, RelatedModel> = .empty,
        queryModifier: QueryModifier<Model> = .empty,
        relationKeyPath: SiblingKeyPath<RelatedModel, Model, Through>) async throws -> Output
    where
        Input: ResourcePatchModel,
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
