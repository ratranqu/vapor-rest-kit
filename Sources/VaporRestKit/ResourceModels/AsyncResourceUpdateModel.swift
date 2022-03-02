//
//  File.swift
//  
//
//  Created by Alex Tran-Qui on 02/03/2022.
//

import Vapor
import Fluent

public protocol AsyncResourceUpdateModel: AsyncResourceMutationModel {
    func update(_: Model) async throws -> Model

    func update(_ model: Model, req: Request, database: Database) async throws -> Model
}


public extension AsyncResourceUpdateModel {
    func update(_ model: Model, req: Request, database: Database) async throws -> Model {
        try await update(model)
    }
}

public extension AsyncResourceUpdateModel {
    func mutate(_ model: Model) async throws -> Model {
        try await update(model)
    }

    func mutate(_ model: Model, req: Request, database: Database) async throws -> Model {
        try await update(model, req: req, database: database)
    }
}
