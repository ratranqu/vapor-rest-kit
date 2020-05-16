//
//  
//  
//
//  Created by Sergey Kazakov on 04.05.2020.
//

import Vapor
import Fluent

//MARK:- CreateChildrenRelationController

struct CreateChildrenRelationController<Model, RelatedModel, Output, EagerLoading>: CreatableRelationController, ChildrenResourceRelationProvider

    where Output: ResourceOutputModel,
          Model == Output.Model,
          RelatedModel: Fluent.Model,
          Model.IDValue: LosslessStringConvertible,
          RelatedModel.IDValue: LosslessStringConvertible,
          EagerLoading: EagerLoadProvider,
          EagerLoading.Model == Model {

    let relationNamePath: String
    let childrenKeyPath: ChildrenKeyPath<RelatedModel, Model>
}

//MARK:- DeleteChildrenRelationController

struct DeleteChildrenRelationController<Model, RelatedModel, Output, DeleteHandler, EagerLoading>:
    DeletableRelationController, ChildrenResourceRelationProvider
    where
        Output: ResourceOutputModel,
        Model == Output.Model,
        Model.IDValue: LosslessStringConvertible,
        DeleteHandler: ResourceDeleteHandler,
        Model == DeleteHandler.Model,
        RelatedModel: Fluent.Model,
        RelatedModel.IDValue: LosslessStringConvertible,
        EagerLoading: EagerLoadProvider,
        EagerLoading.Model == Model {

    let relationNamePath: String
    let childrenKeyPath: ChildrenKeyPath<RelatedModel, Model>

}
