//
//  DataController.swift
//  Mooskine
//
//  Created by Edno Fedulo on 26/05/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    
    let persistentContainer: NSPersistentContainer
    
    init(modelName:String){
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    var viewContext:NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            self.autoSave()
            completion?()
        }
    }
}

extension DataController {
    func autoSave(interval:TimeInterval = 30) {
        guard interval > 0 else {
            print("negative interval, wtf are you doing?")
            return
        }
        
        if viewContext.hasChanges {
            try? viewContext.save()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.autoSave()
        }
    }
}
