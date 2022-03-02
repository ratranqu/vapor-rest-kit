//
//  File.swift
//  
//
//  Created by Alex Tran-Qui on 02/03/2022.
//

import Vapor
import Fluent

struct AsyncSuccessOutput<Model: Fields>: AsyncResourceOutputModel {
    let success: Bool

    init(_ model: Model, req: Request) async throws {
        self.success = true
    }
}

