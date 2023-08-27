//
//  Category.swift
//  MyToDoApp
//
//  Created by Matias Martinelli on 26/08/2023.


import Foundation
//First we import Realm
import RealmSwift

class Category: Object {
    @Persisted var name: String = ""
    @Persisted var items = List<Item>()
    @Persisted var backColor: String = ""
}

