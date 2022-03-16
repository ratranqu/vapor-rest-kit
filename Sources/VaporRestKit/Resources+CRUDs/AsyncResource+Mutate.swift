//
//  File.swift
//  
//
//  Created by Alex Tran-Qui on 16/03/2022.
//

import Vapor
import Fluent
import NIOPosix

extension AsyncResourceController {
    
    @available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
    func mutate<Input, Model>(
        req: Request,
        using: Input.Type,
        queryModifier: QueryModifier<Model>) async throws -> Output
    where
        Input: AsyncResourceMutationModel,
        Output.Model == Model,
        Input.Model == Output.Model {
        
            try Input.validate(content: req)
            let inputModel = try req.content.decode(Input.self)
            
            return try await req.db.transaction { db in
                let model = try await Model.findByIdKey(req, database: db, queryModifier: queryModifier)
                let processedModel = try await inputModel.mutate(model, req: req, database: db)
                try await processedModel.save(on: db)
                return try await Output(processedModel, req: req)
            }
    }
}

extension AsyncRelatedResourceController {
    
    @available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
    func mutate<Input, Model, RelatedModel>(
        resolver: AsyncChildResolver<Model, RelatedModel>,
        req: Request,
        using: Input.Type,
        willSave middleware: AsyncControllerMiddleware<Model, RelatedModel> = .empty,
        queryModifier: QueryModifier<Model>,
        relationKeyPath: ChildrenKeyPath<RelatedModel, Model>) async throws -> Output
    where
        Input: AsyncResourceMutationModel,
        Model == Output.Model,
        Model == Input.Model {
            
            try Input.validate(content: req)
            let inputModel = try req.content.decode(Input.self)
            
            return try await req.db.transaction { db in
                                
                let (model, related) = try await resolver.find(req, db, relationKeyPath, queryModifier)
                
                let (processedModel, processedRelated) = try await middleware.handle(
                                            try await inputModel.mutate(model, req: req, database: db),
                                            relatedModel: related,
                                            req: req,
                                            database: db)

                try processedModel.attached(to: processedRelated, with: relationKeyPath)
                try await processedModel.save(on: db)
                
                return try await Output(processedModel, req: req)

            }
        }
    
    @available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
    func mutate<Input, Model, RelatedModel>(
        resolver: AsyncParentResolver<Model, RelatedModel>,
        req: Request,
        using: Input.Type,
        willSave middleware: AsyncControllerMiddleware<Model, RelatedModel> = .empty,
        queryModifier: QueryModifier<Model>,
        relationKeyPath: ChildrenKeyPath<Model, RelatedModel>) async throws -> Output
    where
        Input: AsyncResourceMutationModel,
        Model == Output.Model,
        Model == Input.Model {

            try Input.validate(content: req)
            let inputModel = try req.content.decode(Input.self)
            let keyPath = relationKeyPath
            return try await req.db.transaction { db in

                let (model, related) = try await resolver.find(req, db, relationKeyPath, queryModifier)
                
                let (processedModel, processedRelated) = try await middleware.handle(
                                            try await inputModel.mutate(model, req: req, database: db),
                                            relatedModel: related,
                                            req: req,
                                            database: db)

                try await processedModel.save(on: db)
                try processedModel.attached(to: processedRelated, with: keyPath)
                try await processedModel.save(on: db)
                try await processedRelated.save(on: db)

                return try await Output(processedModel, req: req)

            }
            
        }
            
    @available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
    func mutate<Input, Model, RelatedModel, Through>(
        resolver: AsyncSiblingsResolver<Model, RelatedModel, Through>,
        req: Request,
        using: Input.Type,
        willSave middleware: AsyncControllerMiddleware<Model, RelatedModel> = .empty,
        queryModifier: QueryModifier<Model>,
        relationKeyPath: SiblingKeyPath<RelatedModel, Model, Through>) async throws -> Output
    where
        Input: AsyncResourceMutationModel,
        Model == Output.Model,
        Model == Input.Model {
        
            
            try Input.validate(content: req)
            let inputModel = try req.content.decode(Input.self)
            
            return try await req.db.transaction { db in
                
                let (model, related) = try await resolver.find(req, db, relationKeyPath, queryModifier)
                
                let (processedModel, processedRelated) = try await middleware.handle(
                                            try await inputModel.mutate(model, req: req, database: db),
                                            relatedModel: related,
                                            req: req,
                                            database: db)

                try await processedModel.save(on: db)
                try await processedModel.attached(to: processedRelated, with: relationKeyPath, on: db)

                return try await Output(processedModel, req: req)
            }

        }
}
