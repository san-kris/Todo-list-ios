//
//  ToDoItemRlm.swift
//  Todoey
//
//  Created by Santosh Krishnamurthy on 1/25/23.
//

import Foundation
import RealmSwift

class ToDoItemRlm: Object {
    @Persisted var title: String = ""
    @Persisted var done: Bool = false
    @Persisted var dateCreated: Double = {
        return Date().timeIntervalSince1970
    }()
    @Persisted(originProperty: "toDoItems") var category: LinkingObjects<CategoryItemRlm>
}
