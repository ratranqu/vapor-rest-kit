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
    func create<Input, Model>(
        req: Request,
        using: Input.Type) async throws -> Output
    where
        Input: AsyncResourceUpdateModel,
        Output.Model == Model,
        Input.Model == Output.Model {

            try Input.validate(content: req)
            let inputModel = try req.content.decode(Input.self)

            return try await req.db.transaction { db in
                let model = try await inputModel
                    .update(Output.Model(), req: req, database: db)
                try await model.save(on: db)
                return try await Output(model, req: req)
            }
    }
}

public extension AsyncRelatedResourceController {
    @available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
    func create<Input, Model, RelatedModel>(
        resolver: AsyncResolver<RelatedModel> = .byIdKeys,
        req: Request,
        using: Input.Type,
        willAttach middleware: AsyncControllerMiddleware<Model, RelatedModel> = .empty,
        relationKeyPath: ChildrenKeyPath<RelatedModel, Model>) async throws -> Output
    where
        Input: AsyncResourceUpdateModel,
        Model == Output.Model,
        Input.Model == Output.Model {
            
            try Input.validate(content: req)
            let inputModel = try req.content.decode(Input.self)
            return try await req.db.transaction { db in
                let (model, related) = try await middleware.handle(try await inputModel.update(Output.Model(), req: req, database: db),
                                            relatedModel: try await resolver.find(req, db),
                                            req: req,
                                            database: db)
                try model.attached(to: related, with: relationKeyPath)
                try await model.save(on: db)
                
                return try await Output(model, req: req)
            }
    }
    
    @available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
    func create<Input, Model, RelatedModel>(
        resolver: AsyncResolver<RelatedModel> = .byIdKeys,
        req: Request,
        using: Input.Type,
        willAttach middleware: AsyncControllerMiddleware<Model, RelatedModel> = .empty,
        relationKeyPath: ChildrenKeyPath<Model, RelatedModel>) async throws -> Output
    where
        Input: AsyncResourceUpdateModel,
        Model == Output.Model,
        Input.Model == Output.Model {
            
            try Input.validate(content: req)
            let inputModel = try req.content.decode(Input.self)
            let keyPath = relationKeyPath

            return try await req.db.transaction { db in
                let (model, related) = try await middleware.handle(try await inputModel.update(Output.Model(), req: req, database: db),
                                            relatedModel: try await resolver.find(req, db),
                                            req: req,
                                            database: db)
                try await model.save(on: db)
                try model.attached(to: related, with: keyPath)
                try await model.save(on: db)
                try await related.save(on: db)

                return try await Output(model, req: req)
            }
        }
    
    @available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
    func create<Input, Model, RelatedModel, Through>(
        resolver: AsyncResolver<RelatedModel> = .byIdKeys,
        req: Request,
        using: Input.Type,
        willAttach middleware: AsyncControllerMiddleware<Model, RelatedModel> = .empty,
        relationKeyPath: SiblingKeyPath<RelatedModel, Model, Through>) async throws -> Output
    where
        Input: AsyncResourceUpdateModel,
        Model == Output.Model,
        Input.Model == Output.Model,
        Through: Fluent.Model {

            try Input.validate(content: req)
            let inputModel = try req.content.decode(Input.self)

            return try await req.db.transaction { db in
                let (model, related) = try await middleware.handle(try await inputModel.update(Output.Model(), req: req, database: db),
                                            relatedModel: try await resolver.find(req, db),
                                            req: req,
                                            database: db)
                try await model.save(on: db)
                try await model.attached(to: related, with: relationKeyPath, on: db)

                return try await Output(model, req: req)
            }
        }
}
