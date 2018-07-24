//
//  FinderSync.swift
//  Finder Extension
//
//  Created by Mortennn on 19/10/2017.
//  Copyright © 2017 Mortennn. All rights reserved.
//

import Cocoa
import FinderSync
import Common
import MMWormhole

class FinderSync: FIFinderSync {
    
    let finderController = FIFinderSyncController.default()
    
    let preferences = Preferences.sharedInstance
    let wormhole = MMWormhole(applicationGroupIdentifier: GlobalVariables.sharedContainerID.rawValue, optionalDirectory: "wormhole")
    
    override init() {
        super.init()
        
        updatePathsToAllowedDirectories()
        
        wormhole.listenForMessage(withIdentifier: "pathsToAllowedDirectoriesHasChanged") { (message) in
            
            self.updatePathsToAllowedDirectories()
            
        }
        
        HelperFunctions.launchHelperApplication()
        
    }
    
    deinit {
        wormhole.stopListeningForMessage(withIdentifier: "pathsToAllowedDirectoriesHasChanged")
    }
    
    override func menu(for menuKind: FIMenuKind) -> NSMenu {
        
        updatePathsToAllowedDirectories()
        
        HelperFunctions.launchHelperApplication()

        // setting the selectedItemURLs to make them available to the initializeContextMenu function
        guard let selectedItemsURL = finderController.selectedItemURLs() else {
            fatalError()
        }
        
        let actionsToBeAppended = FinderSyncCode.getActionsToContextMenu(selectedItemsURL: selectedItemsURL)
        
        let menu = NSMenu(title: "")
        
        for action in actionsToBeAppended {
            let item = menu.addItem(withTitle: action.title!, action:#selector(actionHandler(sender:)), keyEquivalent: "")
            
            if let imageData = action.imageData as Data?,
                let image = NSImage(data: imageData) {
                
                item.image = image
            }
        }
        
        return menu
       
    }
    
    @objc func actionHandler(sender:NSMenuItem) {
        
        HelperFunctions.launchHelperApplication()

        guard let selectedItemsURL = finderController.selectedItemURLs() else {
            fatalError()
        }
        
        let nameOfActionToNS = NSString(string: sender.title)
        let urlsToData = NSKeyedArchiver.archivedData(withRootObject: selectedItemsURL) as NSCoding
        
        let messageObject:NSDictionary = ["nameOfAction" : nameOfActionToNS, "selectedItemsURL" : urlsToData]
        
        wormhole.passMessageObject(messageObject, identifier: "actionPressed")
        
    }

}

extension FinderSync {
    
    fileprivate func updatePathsToAllowedDirectories() {
        // register paths to allowed directories
        if preferences.pathsToAllowedDirectories.count == 0 {
            // watch everything by setting / as the root
            finderController.directoryURLs = [ URL(fileURLWithPath: "/") ]
        } else {
            
            preferences.pathsToAllowedDirectories.forEach { (path) in
                let urlAsFileUrl = URL(fileURLWithPath: path.absoluteString)
                finderController.directoryURLs.insert(urlAsFileUrl)
            }
        }
    }
    
}









