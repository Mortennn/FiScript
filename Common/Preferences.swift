//
//  Preferences.swift
//  Common
//
//  Created by Mortennn on 22/10/2017.
//  Copyright © 2017 Mortennn. All rights reserved.
//

import Foundation

open class Preferences {
    
    public static let sharedInstance = Preferences()
    
    let preferences = UserDefaults(suiteName: GlobalVariables.sharedContainerID.rawValue)!
        
    init() {
        preferences.register(defaults: [
            "HadFirstRun": false
        ])
    }
    
    open var validLicense: Bool {
        get { return preferences.bool(forKey: "validLicense") }
        set { preferences.set(newValue, forKey: "validLicense") }
    }
    
    open var hadFirstRun: Bool {
        get { return preferences.bool(forKey: "HadFirstRun") }
        set { preferences.set(newValue, forKey: "HadFirstRun") }
    }
    
    open var pathsToAllowedDirectories:[URL] {
        get {
            var urls = [URL]()
            
            if let data = preferences.value(forKey: "PathsToAllowedDirectories") as? Data {
                if let urlsArray = NSKeyedUnarchiver.unarchiveObject(with: data) as? [URL] {
                    urls = urlsArray
                }
            }
            
            return urls
            
        }
        set {
            let data = NSKeyedArchiver.archivedData(withRootObject: newValue)
            preferences.setValue(data, forKey: "PathsToAllowedDirectories")
        }
    }
    
    
}


















