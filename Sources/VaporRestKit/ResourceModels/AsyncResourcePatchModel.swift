//
//  File.swift
//  
//
//  Created by Alex Tran-Qui on 02/03/2022.
//

import Vapor
import Fluent

public protocol AsyncResourcePatchModel: AsyncResourceMutationModel {
    func patch(_: Model) async throws -> Model

    func patch(_ model: Model, req: Request, database: Database) async throws -> Model
}

public extension AsyncResourcePatchModel {
    func patch(_ model: Model, req: Request, database: Database) async throws -> Model {
        try await patch(model)
    }
}

public extension AsyncResourcePatchModel {
    func mutate(_ model: Model) async throws -> Model {
        try await patch(model)
    }
    
    func mutate(_ model: Model, req: Request, database: Database) async throws -> Model {
        try await patch(model, req: req, database: database)
    }
}
