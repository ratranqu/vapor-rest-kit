//
//  File.swift
//  
//
//  Created by Alex Tran-Qui on 02/03/2022.
//

import Vapor
import Fluent

public struct AsyncResourceController<Output: AsyncResourceOutputModel> where
    Output.Model.IDValue: LosslessStringConvertible,
    Output.Model: Fluent.Model {

    public init() {

    }
}

public struct AsyncRelatedResourceController<Output: AsyncResourceOutputModel> where
    Output.Model.IDValue: LosslessStringConvertible,
    Output.Model: Fluent.Model {

    public init() {

    }
}

public struct AsyncRelationsController<Output: AsyncResourceOutputModel> where
    Output.Model.IDValue: LosslessStringConvertible,
    Output.Model: Fluent.Model {

    public init() {

    }
}
