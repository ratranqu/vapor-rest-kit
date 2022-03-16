//
//  File.swift
//  
//
//  Created by Alex Tran-Qui on 16/03/2022.
//

import Vapor
import Fluent

//MARK:- InitialMigration

public struct AsyncMigrating<T: Model> {
    public typealias MigratingClosure = (Database) async throws -> Void

    public let name: String
    private let prepareClosure: MigratingClosure
    private let revertClosure: MigratingClosure

    init(name: String,
         with prepareClosure: @escaping MigratingClosure,
         revertClosure: @escaping MigratingClosure) {
        self.name = name
        self.prepareClosure = prepareClosure
        self.revertClosure = revertClosure
    }
}

@available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
extension AsyncMigrating: AsyncMigration {
    public func prepare(on database: Database) async throws {
        try await prepareClosure(database)
    }

    public func revert(on database: Database) async throws {
        try await revertClosure(database)
    }
}

public extension AsyncMigrating {
    static func createInitialMigration(
        with prepare: @escaping MigratingClosure,
        revert: @escaping MigratingClosure = { db in _ = db.schema(T.schema).delete() }) -> AsyncMigrating {

        AsyncMigrating(
            name: "InitialMigration for \(T.schema)",
            with: prepare,
            revertClosure: revert)
    }
}
