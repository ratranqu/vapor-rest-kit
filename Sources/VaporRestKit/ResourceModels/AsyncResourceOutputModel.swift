//
//  File.swift
//  
//
//  Created by Alex Tran-Qui on 02/03/2022.
//

import Vapor
import Fluent

public protocol AsyncResourceOutputModel: Content {
    associatedtype Model: Fields

    init(_: Model, req: Request) async throws
}





