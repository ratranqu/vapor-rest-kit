//
//  
//  
//
//  Created by Sergey Kazakov on 28.04.2020.
//

import Fluent
import Vapor

//MARK:- QueryBuilder Extension

extension QueryBuilder where Model.IDValue: LosslessStringConvertible {
    func getIdParameter(_ idKey: String, from req: Request) throws -> Model.IDValue {
        guard let id = req.parameters.get(idKey, as: Model.IDValue.self) else {
            throw Abort(.badRequest)
        }
        
        return id
    }

    func find(by idKey: String, from req: Request) throws -> EventLoopFuture<Model> {
        let id = try getIdParameter(idKey, from: req)
    
        return self.filter(\._$id == id)
                   .first()
                   .unwrap(or: Abort(.notFound))
    }
    
    @available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
    func find(by idKey: String, from req: Request) async throws -> Model {
        guard let id = try? getIdParameter(idKey, from: req), let model = try await self.filter(\._$id == id).first() else {
            throw Abort(.notFound)
        }
        return model
    }
}

