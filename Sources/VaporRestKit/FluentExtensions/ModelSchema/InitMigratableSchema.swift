//
//  
//  
//
//  Created by Sergey Kazakov on 06.04.2020.
//

import Vapor
import Fluent

//MARK:- InitMigratableSchema

public protocol InitMigratableSchema: Model {
    static func prepare(on schemaBuilder: SchemaBuilder) -> EventLoopFuture<Void>

    static func prepare(on schemaBuilder: SchemaBuilder) async throws
}

public extension InitMigratableSchema {
    static func prepare(on schemaBuilder: SchemaBuilder) async throws {
        try await prepare(on: schemaBuilder).get()
    }
}

public extension InitMigratableSchema {
    static func createInitialMigration() -> Migration {
        Migrating<Self>.createInitialMigration { db in
            prepare(on: db.schema(Self.schema))
        }
    }
}

