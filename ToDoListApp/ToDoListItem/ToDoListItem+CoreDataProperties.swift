//
//  ToDoListItem+CoreDataProperties.swift
//  ToDoListApp
//
//  Created by Büşra Erim on 2.01.2025.
//
//

import Foundation
import CoreData


extension ToDoListItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ToDoListItem> {
        return NSFetchRequest<ToDoListItem>(entityName: "ToDoListItem")
    }

    @NSManaged public var date: Date?
    @NSManaged public var detail: String?
    @NSManaged public var isCompleted: Bool

}

extension ToDoListItem : Identifiable {

}
