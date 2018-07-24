//
//  FinderSyncCode.swift
//  Common
//
//  Created by Mortennn on 04/01/2018.
//  Copyright © 2018 Mortennn. All rights reserved.
//

import Cocoa

public class FinderSyncCode {
    
    public static func getActionsToContextMenu(selectedItemsURL:[URL]) -> [Actions] {
        
        var actions:[Actions] = []
        var actionsToBeAppendedToContextMenu:[Actions] = []
        
        let context = persistentContainer.viewContext
        let request = Actions.createFetchRequest()
        request.returnsObjectsAsFaults = false
        
        do {
            actions = try context.fetch(request)
        } catch {
            fatalError()
        }
        
        var includesFiles = false
        var includesDirectories = false
        
        for url in selectedItemsURL {
            if url.isFile() { includesFiles = true }
            if url.isDirectory { includesDirectories = true }
        }
        
        // Filtering if the actions is enabled
        actions = actions.filter { $0.enabled }
        
        for action in actions {
            if ((action.useOnFiles == includesFiles) || action.useOnFiles) &&
                ((action.useOnDirectories == includesDirectories) || action.useOnDirectories) {
                
                actionsToBeAppendedToContextMenu.append(action)
            }
        }
        
        // Checking if the actions is compatible with the type of the file
        for url in selectedItemsURL {
            for action in actionsToBeAppendedToContextMenu {
                if let acceptedFileTypes = action.acceptedFileTypes {
                    if !acceptedFileTypes.contains("*") && !acceptedFileTypes.contains(url.pathExtension) && !acceptedFileTypes.isEmpty {
                        if let index = actionsToBeAppendedToContextMenu.index(of: action) {
                            actionsToBeAppendedToContextMenu.remove(at: index)
                        }
                    }
                }
            }
        }
        
        // Sorting actionsToBeAppendedToContextMenu by index
        actionsToBeAppendedToContextMenu = actionsToBeAppendedToContextMenu.sorted { $0.index < $1.index }
        
        return actionsToBeAppendedToContextMenu
        
    }

}














