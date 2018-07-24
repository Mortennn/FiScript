//
//  Actions+CoreDataProperties.swift
//  FiScript
//
//  Created by Mortennn on 01/12/2017.
//  Copyright © 2017 Mortennn. All rights reserved.
//
//

import Foundation
import CoreData

public class Actions: NSManagedObject {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Actions> {
        return NSFetchRequest<Actions>(entityName: "Actions")
    }
    
    @nonobjc public class func DeleteAllActionsData(){
        let managedContext = persistentContainer.viewContext
        let request = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: "Actions"))
        
        do {
            try managedContext.execute(request)
        }
        catch {
            print(error)
        }
    }
        
    @NSManaged public var acceptedFileTypes: [String]?
    @NSManaged public var useOnFiles: Bool
    @NSManaged public var useOnDirectories: Bool
    @NSManaged public var actionDescription: String?
    @NSManaged public var confirmBeforeExecuting: Bool
    @NSManaged public var enabled: Bool
    @NSManaged public var getNotificationWhenExecusionHasFinished: Bool
    @NSManaged public var id: Int64
    @NSManaged public var imageData: NSData?
    @NSManaged public var index: Int64
    @NSManaged public var script: String!
    @NSManaged public var shell: String!
    @NSManaged public var title: String!
    
}
