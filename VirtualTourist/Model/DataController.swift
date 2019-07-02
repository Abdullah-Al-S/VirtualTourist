//
//  DataController.swift
//  VirtualTourist
//
//  Created by Arch Studios on 6/25/19.
//  Copyright © 2019 AS. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    static let shared = DataController()
    
    let container = NSPersistentContainer(name: "VirtualTourist")
    
    var context: NSManagedObjectContext {
        return container.viewContext
    }
    
    func load() {
        container.loadPersistentStores { (storeDescription, error) in
            guard error == nil else {
                fatalError("Can't load persistent store")
            }
        }
    }
}
