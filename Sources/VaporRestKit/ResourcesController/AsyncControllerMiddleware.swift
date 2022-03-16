//
//  File.swift
//  
//
//  Created by Alex Tran-Qui on 16/03/2022.
//

import Vapor
import Fluent

public struct AsyncControllerMiddleware<Model: Fluent.Model, RelatedModel: Fluent.Model> {
    public typealias Handler = (Model, RelatedModel, Request, Database) async throws -> (Model, RelatedModel)

    fileprivate let handler: Handler

    public init(handler: @escaping Handler) {
        self.handler = handler
    }

    func handle(_ model: Model,
                relatedModel: RelatedModel,
                req: Request,
                database: Database) async throws-> (Model, RelatedModel) {

        try await handler(model, relatedModel, req, database)
    }
}

public extension AsyncControllerMiddleware {
    static var empty: AsyncControllerMiddleware<Model, RelatedModel> {
        AsyncControllerMiddleware { model, relatedModel, req, _ in
            (model, relatedModel)
        }
    }
}
