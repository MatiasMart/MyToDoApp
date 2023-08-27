//
//  Item.swift
//  MyToDoApp
//
//  Created by Matias Martinelli on 26/08/2023.

import Foundation
//First we import Realm
import RealmSwift

//Then we create the item object of type Object, with 3 attributes, name, done and the linking to the parent category -
//with LinkingObject
class Item: Object {
    @Persisted var title: String = ""
    @Persisted var done: Bool = false
    @Persisted var dateCreated: Date = Date()
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}

