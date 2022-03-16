//
//  File.swift
//  
//
//  Created by Alex Tran-Qui on 16/03/2022.
//

import Fluent
import Vapor

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
