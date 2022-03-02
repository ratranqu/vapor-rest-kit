//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 09.08.2021.
//

import Vapor
import Fluent

public struct ChildResolver<Model, RelatedModel>
where
    Model: Fluent.Model,
    RelatedModel: Fluent.Model,
    RelatedModel.IDValue: LosslessStringConvertible,
    Model.IDValue: LosslessStringConvertible {

    let find: (_ req: Request,
               _ db: Database,
               _ keyPath: ChildrenKeyPath<RelatedModel, Model>,
               _ queryModifier: QueryModifier<Model>) throws -> EventLoopFuture<(Model, RelatedModel)>
}

public extension ChildResolver {
    static func requireAuth() -> ChildResolver where RelatedModel: Authenticatable {
        ChildResolver(find: Model.findByIdKeyAndAuthRelated)
    }

    static var byIdKeys: ChildResolver {
        ChildResolver(find: Model.findByIdKeys)
    }
}

public struct ParentResolver<Model, RelatedModel>
where
    Model: Fluent.Model,
    RelatedModel: Fluent.Model,
    RelatedModel.IDValue: LosslessStringConvertible,
    Model.IDValue: LosslessStringConvertible {

    let find: (_ req: Request,
               _ db: Database,
               _ keyPath: ChildrenKeyPath<Model, RelatedModel>,
               _ queryModifier: QueryModifier<Model>) throws -> EventLoopFuture<(Model, RelatedModel)>
}

public extension ParentResolver {
    static func requireAuth() -> ParentResolver where RelatedModel: Authenticatable {
        ParentResolver(find: Model.findByIdKeyAndAuthRelated)
    }

    static var byIdKeys: ParentResolver {
        ParentResolver(find: Model.findByIdKeys)
    }
}


public struct SiblingsResolver<Model, RelatedModel, Through>
where
    Model: Fluent.Model,
    Through: Fluent.Model,
    RelatedModel: Fluent.Model,
    RelatedModel.IDValue: LosslessStringConvertible,
    Model.IDValue: LosslessStringConvertible {

    let find: (_ req: Request,
               _ db: Database,
               _ keyPath: SiblingKeyPath<RelatedModel, Model, Through>,
               _ queryModifier: QueryModifier<Model>) throws -> EventLoopFuture<(Model, RelatedModel)>
}

public extension SiblingsResolver {
    static func requireAuth() -> SiblingsResolver where RelatedModel: Authenticatable {

        SiblingsResolver(find: Model.findByIdKeyAndAuthRelated)
    }

    static var byIdKeys: SiblingsResolver {
        SiblingsResolver(find: Model.findByIdKeys)
    }
}

public struct Resolver<Model> where Model: Fluent.Model,
                             Model.IDValue: LosslessStringConvertible {

    let find: (_ req: Request,
               _ db: Database) throws -> EventLoopFuture<Model>
}

public extension Resolver {
    static func requireAuth() -> Resolver where Model: Authenticatable {
        Resolver(find: Model.requireAuth)
    }

    static var byIdKeys: Resolver {
        Resolver(find: Model.findByIdKey)
    }
}

public struct AsyncChildResolver<Model, RelatedModel>
where
    Model: Fluent.Model,
    RelatedModel: Fluent.Model,
    RelatedModel.IDValue: LosslessStringConvertible,
    Model.IDValue: LosslessStringConvertible {

    let find: (_ req: Request,
               _ db: Database,
               _ keyPath: ChildrenKeyPath<RelatedModel, Model>,
               _ queryModifier: QueryModifier<Model>) async throws -> (Model, RelatedModel)
}

public extension AsyncChildResolver {
    static func requireAuth() -> AsyncChildResolver where RelatedModel: Authenticatable {
        AsyncChildResolver(find: Model.findByIdKeyAndAuthRelated)
    }

    static var byIdKeys: AsyncChildResolver {
        AsyncChildResolver(find: Model.findByIdKeys)
    }
}

public struct AsyncParentResolver<Model, RelatedModel>
where
    Model: Fluent.Model,
    RelatedModel: Fluent.Model,
    RelatedModel.IDValue: LosslessStringConvertible,
    Model.IDValue: LosslessStringConvertible {

    let find: (_ req: Request,
               _ db: Database,
               _ keyPath: ChildrenKeyPath<Model, RelatedModel>,
               _ queryModifier: QueryModifier<Model>) async throws -> (Model, RelatedModel)
}

public extension AsyncParentResolver {
    static func requireAuth() -> AsyncParentResolver where RelatedModel: Authenticatable {
        AsyncParentResolver(find: Model.findByIdKeyAndAuthRelated)
    }

    static var byIdKeys: AsyncParentResolver {
        AsyncParentResolver(find: Model.findByIdKeys)
    }
}


public struct AsyncSiblingsResolver<Model, RelatedModel, Through>
where
    Model: Fluent.Model,
    Through: Fluent.Model,
    RelatedModel: Fluent.Model,
    RelatedModel.IDValue: LosslessStringConvertible,
    Model.IDValue: LosslessStringConvertible {

    let find: (_ req: Request,
               _ db: Database,
               _ keyPath: SiblingKeyPath<RelatedModel, Model, Through>,
               _ queryModifier: QueryModifier<Model>) async throws -> (Model, RelatedModel)
}

public extension AsyncSiblingsResolver {
    static func requireAuth() -> AsyncSiblingsResolver where RelatedModel: Authenticatable {

        AsyncSiblingsResolver(find: Model.findByIdKeyAndAuthRelated)
    }

    static var byIdKeys: AsyncSiblingsResolver {
        AsyncSiblingsResolver(find: Model.findByIdKeys)
    }
}

public struct AsyncResolver<Model> where Model: Fluent.Model,
                             Model.IDValue: LosslessStringConvertible {

    let find: (_ req: Request,
               _ db: Database) async throws -> Model
}

public extension AsyncResolver {
    static func requireAuth() -> AsyncResolver where Model: Authenticatable {
        AsyncResolver(find: Model.requireAuth)
    }

    static var byIdKeys: AsyncResolver {
        AsyncResolver(find: Model.findByIdKey)
    }
}

