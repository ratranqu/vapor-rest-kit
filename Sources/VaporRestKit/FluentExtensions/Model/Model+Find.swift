//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 18.07.2021.
//

import Vapor
import Fluent

extension Model where IDValue: LosslessStringConvertible {
    static func findByIdKey(_ req: Request,
                            database: Database) throws -> EventLoopFuture<Self> {
        try findByIdKey(
            req,
            database: database,
            queryModifier: .empty)
    }

    static func findByIdKey(_ req: Request,
                            database: Database,
                            queryModifier: QueryModifier<Self>) throws -> EventLoopFuture<Self> {
        try Self.query(on: database)
            .with(queryModifier, for: req)
            .find(by: idKey, from: req)
    }
    
    static func findByIdKey(_ req: Request,
                            database: Database) async throws -> Self {
        try await findByIdKey(
            req,
            database: database).get()
    }

    static func findByIdKey(_ req: Request,
                            database: Database,
                            queryModifier: QueryModifier<Self>) async throws -> Self {
        try await findByIdKey(
            req,
            database: database,
            queryModifier: queryModifier).get()
    }
}

extension Model where Self: Authenticatable {
    static func requireAuth(_ req: Request,
                            database: Database) throws -> EventLoopFuture<Self>  {

        let related = try req.auth.require(Self.self)
        return req.eventLoop.makeSucceededFuture(related)
    }
    
    static func requireAuth(_ req: Request,
                            database: Database) throws -> Self  {
        try req.auth.require(Self.self)
    }
}

//Parent - Children

extension Model where IDValue: LosslessStringConvertible {
    static func findByIdKeys<RelatedModel>(
        _ req: Request,
        database: Database,
        childrenKeyPath: ChildrenKeyPath<RelatedModel, Self>,
        queryModifier: QueryModifier<Self>) throws -> EventLoopFuture<(Self, RelatedModel)>

    where
        RelatedModel: Fluent.Model,
        RelatedModel.IDValue: LosslessStringConvertible {

        try RelatedModel
            .query(on: database)
            .find(by: RelatedModel.idKey, from: req)
            .flatMapThrowing { related in
                try related
                    .queryRelated(keyPath: childrenKeyPath, on: database)
                    .with(queryModifier, for: req)
                    .find(by: idKey, from: req)
                    .and(value: related)
            }
            .flatMap { $0 }
    }

    static func findByIdKeyAndAuthRelated<RelatedModel>(
        _ req: Request,
        database: Database,
        childrenKeyPath: ChildrenKeyPath<RelatedModel, Self>,
        queryModifier: QueryModifier<Self>) throws -> EventLoopFuture<(Self, RelatedModel)>

    where
        RelatedModel: Fluent.Model,
        RelatedModel.IDValue: LosslessStringConvertible,
        RelatedModel: Authenticatable {

        let related = try req.auth.require(RelatedModel.self)
        return req.eventLoop
            .makeSucceededFuture(related)
            .flatMapThrowing { related in
                try related
                    .queryRelated(keyPath: childrenKeyPath, on: database)
                    .with(queryModifier, for: req)
                    .find(by: idKey, from: req)
                    .and(value: related)
            }
            .flatMap { $0 }
    }
    
    static func findByIdKeys<RelatedModel>(
        _ req: Request,
        database: Database,
        childrenKeyPath: ChildrenKeyPath<RelatedModel, Self>,
        queryModifier: QueryModifier<Self>) async throws -> (Self, RelatedModel)

    where
        RelatedModel: Fluent.Model,
        RelatedModel.IDValue: LosslessStringConvertible {

        try await findByIdKeys(
            req,
            database: database,
            childrenKeyPath: childrenKeyPath,
            queryModifier: queryModifier).get()
    }

    static func findByIdKeyAndAuthRelated<RelatedModel>(
        _ req: Request,
        database: Database,
        childrenKeyPath: ChildrenKeyPath<RelatedModel, Self>,
        queryModifier: QueryModifier<Self>) async throws -> (Self, RelatedModel)

    where
        RelatedModel: Fluent.Model,
        RelatedModel.IDValue: LosslessStringConvertible,
        RelatedModel: Authenticatable {

            try await findByIdKeyAndAuthRelated(
                req,
                database: database,
                childrenKeyPath: childrenKeyPath,
                queryModifier: queryModifier).get()
    }
}


//Child- Parent

extension Model where IDValue: LosslessStringConvertible {

    static func findByIdKeys<RelatedModel>(
        _ req: Request,
        database: Database,
        childrenKeyPath: ChildrenKeyPath<Self, RelatedModel>,
        queryModifier: QueryModifier<Self>) throws -> EventLoopFuture<(Self, RelatedModel)>

    where
        RelatedModel: Fluent.Model,
        RelatedModel.IDValue: LosslessStringConvertible {

        try RelatedModel
            .query(on: database)
            .find(by: RelatedModel.idKey, from: req)
            .flatMapThrowing { related in
                try related
                    .queryRelated(keyPath: childrenKeyPath, on: database)
                    .with(queryModifier, for: req)
                    .find(by: idKey, from: req)
                    .and(value: related)
            }
            .flatMap { $0 }
    }

    static func findByIdKeyAndAuthRelated<RelatedModel>(
        _ req: Request,
        database: Database,
        childrenKeyPath: ChildrenKeyPath<Self, RelatedModel>,
        queryModifier: QueryModifier<Self>) throws -> EventLoopFuture<(Self, RelatedModel)>

    where
        RelatedModel: Fluent.Model,
        RelatedModel.IDValue: LosslessStringConvertible,
        RelatedModel: Authenticatable {

        let related = try req.auth.require(RelatedModel.self)
        return req.eventLoop
            .makeSucceededFuture(related)
            .flatMapThrowing { related in
                try related
                    .queryRelated(keyPath: childrenKeyPath, on: database)
                    .with(queryModifier, for: req)
                    .find(by: idKey, from: req)
                    .and(value: related)
            }
            .flatMap { $0 }
    }
    
    static func findByIdKeys<RelatedModel>(
        _ req: Request,
        database: Database,
        childrenKeyPath: ChildrenKeyPath<Self, RelatedModel>,
        queryModifier: QueryModifier<Self>) async throws -> (Self, RelatedModel)

    where
        RelatedModel: Fluent.Model,
        RelatedModel.IDValue: LosslessStringConvertible {

        try await findByIdKeys(
            req,
            database: database,
            childrenKeyPath: childrenKeyPath,
            queryModifier: queryModifier).get()
    }

    static func findByIdKeyAndAuthRelated<RelatedModel>(
        _ req: Request,
        database: Database,
        childrenKeyPath: ChildrenKeyPath<Self, RelatedModel>,
        queryModifier: QueryModifier<Self>) async throws -> (Self, RelatedModel)

    where
        RelatedModel: Fluent.Model,
        RelatedModel.IDValue: LosslessStringConvertible,
        RelatedModel: Authenticatable {

            try await findByIdKeyAndAuthRelated(
                req,
                database: database,
                childrenKeyPath: childrenKeyPath,
                queryModifier: queryModifier).get()
    }
}


//Siblings

extension Model where IDValue: LosslessStringConvertible {
    static func findByIdKeys<RelatedModel, Through>(
        _ req: Request,
        database: Database,
        siblingKeyPath: SiblingKeyPath<RelatedModel, Self, Through>,
        queryModifier: QueryModifier<Self>) throws -> EventLoopFuture<(Self, RelatedModel)>

    where
        Through: Fluent.Model,
        RelatedModel.IDValue: LosslessStringConvertible {

        try RelatedModel
            .query(on: database)
            .find(by: RelatedModel.idKey, from: req)
            .flatMapThrowing { related in
                try related.queryRelated(keyPath: siblingKeyPath, on: database)
                    .with(queryModifier, for: req)
                    .find(by: idKey, from: req)
                    .and(value: related)
            }
            .flatMap { $0 }
    }

    static func findByIdKeyAndAuthRelated<RelatedModel, Through>(
        _ req: Request,
        database: Database,
        siblingKeyPath: SiblingKeyPath<RelatedModel, Self, Through>,
        queryModifier: QueryModifier<Self>) throws -> EventLoopFuture<(Self, RelatedModel)>

    where
        Through: Fluent.Model,
        RelatedModel.IDValue: LosslessStringConvertible,
        RelatedModel: Authenticatable {

        let related = try req.auth.require(RelatedModel.self)
        return req.eventLoop
            .makeSucceededFuture(related)
            .flatMapThrowing { related in
                try related.queryRelated(keyPath: siblingKeyPath, on: database)
                    .with(queryModifier, for: req)
                    .find(by: idKey, from: req)
                    .and(value: related)
            }
            .flatMap { $0 }
    }
    
    static func findByIdKeys<RelatedModel, Through>(
        _ req: Request,
        database: Database,
        siblingKeyPath: SiblingKeyPath<RelatedModel, Self, Through>,
        queryModifier: QueryModifier<Self>) async throws -> (Self, RelatedModel)

    where
        Through: Fluent.Model,
        RelatedModel.IDValue: LosslessStringConvertible {

        try await findByIdKeys(
            req,
            database: database,
            siblingKeyPath: siblingKeyPath,
            queryModifier: queryModifier).get()
    }

    static func findByIdKeyAndAuthRelated<RelatedModel, Through>(
        _ req: Request,
        database: Database,
        siblingKeyPath: SiblingKeyPath<RelatedModel, Self, Through>,
        queryModifier: QueryModifier<Self>) async throws -> (Self, RelatedModel)

    where
        Through: Fluent.Model,
        RelatedModel.IDValue: LosslessStringConvertible,
        RelatedModel: Authenticatable {

            try await findByIdKeyAndAuthRelated(
                req,
                database: database,
                siblingKeyPath: siblingKeyPath,
                queryModifier: queryModifier).get()
    }
}
