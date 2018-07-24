//
//  HelperFunctions.swift
//  Common
//
//  Created by Mortennn on 21/04/2018.
//  Copyright © 2018 Mortennn. All rights reserved.
//

import Cocoa

public class HelperFunctions {
    
    public static func launchHelperApplication() {
        
        // checking if the helper application is active
        
        let helperAppURL = URL(fileURLWithPath: "/Applications/FiScript.app/Contents/PlugIns/FiScriptHelper.app")
        
        let conf = [NSWorkspace.LaunchConfigurationKey:Any]()
        do {
            try NSWorkspace.shared.launchApplication(at: helperAppURL, options: NSWorkspace.LaunchOptions.withErrorPresentation, configuration: conf)
        } catch {
            #if !DEBUG
                if !FileManager.default.fileExists(atPath: helperAppURL.path) {
                    // helper application doesn't exist at path
                    let a = NSAlert()
                    a.messageText = "Can't communicate with helper application."
                    a.informativeText = "Check if Helper applications exists at \(helperAppURL.path) Helper application has been moved or deleted. Please move the helper application back or reinstall FiScript."
                    a.addButton(withTitle: "OK")
                    a.alertStyle = .critical
                    a.runModal()
                } else {
                    let a = NSAlert()
                    a.messageText = "Helper Application Couldn't Launch"
                    a.informativeText = "Helper application couldn't launch. Please try again."
                    a.addButton(withTitle: "OK")
                    a.alertStyle = .critical
                    a.runModal()
                }
            #endif
        }
        
    }
        
}
