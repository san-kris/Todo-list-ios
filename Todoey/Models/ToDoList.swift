//
//  ToDoList.swift
//  Todoey
//
//  Created by Santosh Krishnamurthy on 1/22/23.
//

import Foundation

class ToDoList {
    var items = [ToDoListItem]()
    
    init() {
    }
    
    init(items: [ToDoListItem]) {
        self.items = items
    }
    
    init(stringArray: [String]) {
        for item in stringArray{
            items.append(ToDoListItem(title: item, done: false))
        }
    }
    
    func add(title: String, done: Bool = false) -> Void {
        items.append(ToDoListItem(title: title, done: done))
    }
}
