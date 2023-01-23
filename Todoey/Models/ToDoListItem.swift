//
//  ToDoListItem.swift
//  Todoey
//
//  Created by Santosh Krishnamurthy on 1/22/23.
//

import Foundation

struct ToDoListItem: Encodable, Decodable{
    let title: String
    var done: Bool = false
    
    init(title: String, done: Bool) {
        self.title = title
        self.done = done
    }
}
