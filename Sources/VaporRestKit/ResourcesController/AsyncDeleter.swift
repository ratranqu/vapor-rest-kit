//
//  File.swift
//  
//
//  Created by Alex Tran-Qui on 16/03/2022.
//

import Vapor
import Fluent

public struct AsyncDeleter<Model: Fluent.Model> {
    public typealias Handler = (Model, Bool, Request, Database) async throws -> Model

    private let handler: Handler
    private let useForcedDelete: Bool

    public init(useForcedDelete: Bool = false,
                handler: @escaping Handler = Self.defaultDeleteHandler) {
        self.handler = handler
        self.useForcedDelete = useForcedDelete
    }

    public static func defaultDeleteHandler(_ model: Model,
                                            forceDelete: Bool,
                                            req: Request,
                                            db: Database) async throws -> Model {

        _ = try await model.delete(force: forceDelete, on: db).get()
        return model
    }

    func performDelete(_ model: Model,
                       req: Request,
                       database: Database) async throws -> Model {

        try await handler(model, useForcedDelete, req, database)
    }
}

public extension AsyncDeleter {
    static func defaultDeleter(useForcedDelete: Bool = false) -> AsyncDeleter<Model> {
        AsyncDeleter(useForcedDelete: useForcedDelete)  { model, forceDelete, _, db in
            _ = try await model.delete(force: forceDelete, on: db).get()
            return model
        }
    }
}
