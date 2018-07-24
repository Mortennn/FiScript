//
//  AppDelegate.swift
//  FiScript
//
//  Created by Mortennn on 19/10/2017.
//  Copyright © 2017 Mortennn. All rights reserved.
//

import Cocoa
import Common
import MMWormhole

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, DM_SUUpdaterDelegate {
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        
        #if DEBUG
//            Preferences.sharedInstance.hadFirstRun = false
//            Actions.DeleteAllActionsData()
//            exit(0)
        #endif
        
        HelperFunctions.launchHelperApplication()
        
        DevMateKit.sendTrackingReport(nil, delegate: nil)

        // Issues
        DevMateKit.setupIssuesController(nil, reportingUnhandledIssues: true)
        
        // Updates
        DM_SUUpdater.shared().delegate = self
        
    }
    
    func updaterShouldPromptForPermissionToCheck(forUpdates updater: DM_SUUpdater) -> Bool {
        return true
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    @IBAction func showFeedbackDialog(sender: AnyObject?) {
        DevMateKit.showFeedbackDialog(nil, in: DMFeedbackMode.independentMode)
    }
    
}
