//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 18.05.2020.
//

import Fluent
import Vapor

extension Database {
    func tryTransaction<T>(_ closure: @escaping (Database) throws -> EventLoopFuture<T>) -> EventLoopFuture<T> {
        transaction { (db) -> EventLoopFuture<T> in
            db.context.eventLoop
                .tryFuture { try closure(db) }
                .flatMap { $0 }
        }

    }
}
#if compiler(>=5.5) && canImport(_Concurrency)
@available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
extension Database {
    func tryTransaction<T>(_ closure: @escaping (Database) async throws -> T) async throws -> T {
        try await transaction { (db) -> T in
            try await closure(db)
        }

    }

}
#endif
