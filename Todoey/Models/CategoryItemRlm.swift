//
//  CategoryItemRlm.swift
//  Todoey
//
//  Created by Santosh Krishnamurthy on 1/25/23.
//

import Foundation
import RealmSwift

class CategoryItemRlm: Object {
    @Persisted var name: String = ""
    @Persisted var toDoItems = List<ToDoItemRlm>()
}
