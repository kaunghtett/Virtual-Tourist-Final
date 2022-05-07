//
//  DataController.swift
//  Virtual Tourist Udacity
//
//  Created by Min Kaung Htet on 06/05/2022.
//

import Foundation
import CoreData

class DataController {
    
    let persistentContainer:NSPersistentContainer
    
    var viewContext:NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    init(model :String) {
        persistentContainer = NSPersistentContainer(name: model)
    }
    
    func configureContexts() {
        viewContext.automaticallyMergesChangesFromParent = true
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
    }
    
    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            self.autoSaveViewContext()
            self.configureContexts()
            completion?()
        }
    }
    
    // save current context
    func save() throws {
        if viewContext.hasChanges {
            try viewContext.save()
        }
    }
    
    static let shared = DataController(model: "Virtual_Tourist_Udacity")
}

// MARK: - Autosaving
extension DataController {
    func autoSaveViewContext(interval:TimeInterval = 30) {
        print("autosaving")
        
        guard interval > 0 else {
            print("cannot set negative autosave interval")
            return
        }
        
        if viewContext.hasChanges {
            try? viewContext.save()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.autoSaveViewContext(interval: interval)
        }
    }
}

extension DataController {
    
    func fetchLocation(_ predicate: NSPredicate, sorting: NSSortDescriptor? = nil) throws -> Pin? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        fetchRequest.predicate = predicate
        if let sorting = sorting {
            fetchRequest.sortDescriptors = [sorting]
        }
        guard let location = (try viewContext.fetch(fetchRequest) as! [Pin]).first else {
            return nil
        }
        return location
    }
    
    func fetchAllLocation() throws -> [Pin]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        guard let pin = try viewContext.fetch(fetchRequest) as? [Pin] else {
            return nil
        }
        return pin
    }
    
    func fetchAllPhoto(_ predicate: NSPredicate? = nil, sorting: NSSortDescriptor? = nil) throws -> [Photo]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        fetchRequest.predicate = predicate
        if let sorting = sorting {
            fetchRequest.sortDescriptors = [sorting]
        }
        guard let allPhoto = try viewContext.fetch(fetchRequest) as? [Photo] else {
            return nil
        }
        return allPhoto
    }
}
