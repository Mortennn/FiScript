//
//  AppDelegate.swift
//  FiScriptHelper
//
//  Created by Mortennn on 17/12/2017.
//  Copyright © 2017 Mortennn. All rights reserved.
//

import Cocoa
import Common
import MMWormhole

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let sharedUserDefaults = UserDefaults(suiteName: GlobalVariables.sharedContainerID.rawValue)!
    let wormhole = MMWormhole(applicationGroupIdentifier: GlobalVariables.sharedContainerID.rawValue, optionalDirectory: "wormhole")
    
    deinit {
        wormhole.stopListeningForMessage(withIdentifier: GlobalVariables.sharedContainerID.rawValue)
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        wormhole.listenForMessage(withIdentifier: "activateAppInPreferences", listener: { (message) -> Void in
            self.activateAppInPreferences()
//            NSApplication.shared.terminate(nil)
        })
        
        wormhole.listenForMessage(withIdentifier: "actionPressed", listener: { (message) -> Void in
            
            let messageObject = message as AnyObject
            
            guard let messageDic = messageObject as? Dictionary<String, Any>,
                let nameOfActionData = messageDic.filter({ $0.key == "nameOfAction" }).first,
                let selectedItemsURLData = messageDic.filter({ $0.key == "selectedItemsURL" }).first,
                let nameOfAction = nameOfActionData.value as? String,
                let selectedItemsURL = NSKeyedUnarchiver.unarchiveObject(with: selectedItemsURLData.value as! Data) as? [URL] else {
                    // helper application couldn't execute action
                    fatalError()
            }
            
            var action:Actions?

            let context = persistentContainer.viewContext
            let request = Actions.createFetchRequest()
            request.predicate = NSPredicate(format: "title == \"\(nameOfAction)\"")

            do {
                action = try context.fetch(request).first!
            } catch {
                fatalError()
            }
            
            func executeAction() {

                guard var script = action?.script,
                    let shell = action?.shell else {
                        fatalError()
                }

                // execute the script on each of the selected files/directories
                for url in selectedItemsURL {

                    // replacing the references to filenames
                    guard let dir = Bundle.main.resourceURL else {
                        fatalError("Couldn't locate resource directory")
                    }

                    // getting the current directory path
                    var currentDirectory: String {
                        get {
                            if url.isFile() {
                                return url.deletingLastPathComponent().path
                            } else {
                                return url.path
                            }
                        }
                    }

                    let tmpScript = script.replacingOccurrences(of: "$PATH", with: "\"\(url.path)\"")
                    let scriptURL = dir.appendingPathComponent("tmp.sh")
                    var newScript = ""
                    newScript.append("#!\(shell)")
                    newScript.append("\n")
                    newScript.append(tmpScript)

                    guard let newScriptData = newScript.data(using: .utf8) else {
                        fatalError("can't convert script to data")
                    }

                    // give script executable permission
                    var attributes = [FileAttributeKey : Any]()
                    attributes[.posixPermissions] = 0o777
                    FileManager.default.createFile(atPath: scriptURL.path, contents: newScriptData, attributes: attributes)
                    
                    // execute script
                    let pipe = Pipe()
                    let process = Process()
                    process.launchPath = scriptURL.path
                    process.currentDirectoryPath = currentDirectory
                    process.standardOutput = pipe
                    process.launch()
                    process.waitUntilExit()

                    // deleting the script
                    do {
                        try FileManager.default.removeItem(at: scriptURL)
                    } catch {
                        fatalError("Couldn't delete the script")
                    }
                }

                if action!.getNotificationWhenExecusionHasFinished {
                    self.displayNotification(title: "Action has finished!", body: "\(action!.title!) has finished!")
                }
            }

            // checking if the action should be confirmed
            if action!.confirmBeforeExecuting {
                let shouldContinue = self.confirmExecution(title: "Warning", body: "Are you sure you want to execute \(action!.title!)?")
                if shouldContinue { executeAction() }
            } else {
                executeAction()
            }
       
//            NSApplication.shared.terminate(nil)
        })

    }
    
    func confirmExecution(title: String, body: String) -> Bool {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = body
        alert.alertStyle = .critical
        alert.addButton(withTitle: "Yes")
        alert.addButton(withTitle: "No")
        alert.window.level = .modalPanel
        return alert.runModal() == .alertFirstButtonReturn
    }
    
    func displayNotification(title:String, body:String) {
        let notification = NSUserNotification()
        notification.title = title
        notification.informativeText = body
        notification.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    fileprivate func activateAppInPreferences() {
        let pipe = Pipe()
        let process = Process()
        process.launchPath = "/usr/bin/pluginkit"
        process.arguments = ["-e", "use", "-i", "com.Mortennn.FiScript.Finder-Extension"]
        process.standardOutput = pipe
        process.launch()
        
        process.waitUntilExit()
        
    }
    
}

