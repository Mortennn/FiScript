//
//  CoreDataExtensions.swift
//  Common
//
//  Created by Mortennn on 24/11/2017.
//  Copyright © 2017 Mortennn. All rights reserved.
//

import CoreData

// MARK: - Core Data stack
public var managedObjectModel: NSManagedObjectModel = {
    let sexyFrameworkBundleIdentifier = GlobalVariables.commonBundleID.rawValue
    let customKitBundle = Bundle(identifier: sexyFrameworkBundleIdentifier)!
    let modelURL = customKitBundle.url(forResource: "Model", withExtension: "momd")!
    return NSManagedObjectModel(contentsOf: modelURL)!
}()

public var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "Model.xcdatamodeld", managedObjectModel: managedObjectModel)
    var persistentStoreDescriptions: NSPersistentStoreDescription
    let storeUrl =  FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "\(GlobalVariables.sharedContainerID).container")!.appendingPathComponent("DataModel.sqlite")
    
    let description = NSPersistentStoreDescription()
    description.shouldInferMappingModelAutomatically = true
    description.shouldMigrateStoreAutomatically = true
    description.url = storeUrl
    
    container.persistentStoreDescriptions = [NSPersistentStoreDescription(url:  FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "\(GlobalVariables.sharedContainerID).container")!.appendingPathComponent("DataModel.sqlite"))]
    
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
        if let error = error {
            fatalError("Unresolved error \(error)")
        }
    })
    return container
}()
