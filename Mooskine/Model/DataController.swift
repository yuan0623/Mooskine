//
//  DataController.swift
//  Mooskine
//
//  Created by Yuan Gao on 12/6/22.
//  Copyright © 2022 Udacity. All rights reserved.
//

import Foundation
import CoreData

class DataController{
    let persistentContainer:NSPersistentContainer
    var viewContext:NSManagedObjectContext{
        return persistentContainer.viewContext
    }
    var backgroundContext:NSManagedObjectContext!
    
    init(modelName:String){
        persistentContainer = NSPersistentContainer(name: modelName)
 
    }
    
    func configureContexts(){
        backgroundContext = persistentContainer.newBackgroundContext()
        viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext.automaticallyMergesChangesFromParent = true
        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
    }
    
    func load(completion: (()->Void)?=nil){
        persistentContainer.loadPersistentStores { storeDescription, error in
            guard error == nil else{
                fatalError(error!.localizedDescription)
            }
            self.autoSaveViewContext(interval: 3)
            self.configureContexts()
            completion?()
        }
    }
}


extension DataController{
    func autoSaveViewContext(interval:TimeInterval = 30){
        print("auto save")
        guard interval>0 else{
            print("cannott set negative autosave interval")
            return
        }
        if viewContext.hasChanges{
            try? viewContext.save()
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+interval){
            self.autoSaveViewContext(interval: interval)
        }
    }
}
