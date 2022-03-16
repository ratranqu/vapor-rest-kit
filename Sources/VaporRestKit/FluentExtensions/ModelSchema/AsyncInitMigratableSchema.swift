//
//  File.swift
//  
//
//  Created by Alex Tran-Qui on 16/03/2022.
//

import Vapor
import Fluent

//MARK:- InitMigratableSchema

public protocol AsyncInitMigratableSchema: Model {
    static func prepare(on schemaBuilder: SchemaBuilder) async throws
}

@available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
public extension AsyncInitMigratableSchema {
    static func createInitialMigration() -> AsyncMigration {
        AsyncMigrating<Self>.createInitialMigration { db in
            try await prepare(on: db.schema(Self.schema))
        }
    }
}
