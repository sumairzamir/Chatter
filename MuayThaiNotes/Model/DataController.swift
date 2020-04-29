//
//  DataController.swift
//  MuayThaiNotes
//
//  Created by Aiman Nabeel on 28/04/2020.
//  Copyright © 2020 Sumair Zamir. All rights reserved.
//

import Foundation
import CoreData

// Boilerplate code required to instantiate the DataController and persistant store.
class DataController {
    
    let persistantContainer: NSPersistentContainer
    var viewContext: NSManagedObjectContext {
        return persistantContainer.viewContext
    }
    
    init(modelName: String) {
        persistantContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completionHandler: (() -> Void)? = nil) {
        persistantContainer.loadPersistentStores { (storeDescription, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            completionHandler?()
        }
    }
    
}
