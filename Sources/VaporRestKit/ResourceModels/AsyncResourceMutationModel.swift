//
//  File.swift
//  
//
//  Created by Alex Tran-Qui on 02/03/2022.
//

import Vapor
import Fluent
import Foundation

public protocol AsyncResourceMutationModel: Content, Validatable where Model: Fields {
    associatedtype Model

    func mutate(_: Model) async throws -> Model

    func mutate(_ model: Model, req: Request, database: Database) async throws -> Model
}

public extension AsyncResourceMutationModel {
    func mutate(_ model: Model, req: Request, database: Database) async throws -> Model {
        try await mutate(model)
    }
}
