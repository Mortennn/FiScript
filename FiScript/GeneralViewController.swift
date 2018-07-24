//
//  GeneralViewController.swift
//  FiScript
//
//  Created by Mortennn on 31/10/2017.
//  Copyright © 2017 Mortennn. All rights reserved.
//

import Cocoa
import Common
import MMWormhole

class GeneralViewController: NSViewController {

    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var pathColumn: NSTableColumn!

    let preferences = Preferences.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        tableView.target = self

    }

    override func viewDidAppear() {
        super.viewDidAppear()
        
        if preferences.hadFirstRun == false {
            preferences.hadFirstRun = true
            
            DefaultActions.saveDefaultActions()
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
            
            // MARK: - alert for making sure the user activates the extension
            #if !DEBUG
                let a = NSAlert()
                a.messageText = "Please Enable FiScript in Finder"
                a.informativeText = "FiScript needs to be enabled in Finder to work properly. You can always deactivate FiScript under System Preferences.app > Extensions"
                a.addButton(withTitle: "Enable FiScript")
                a.addButton(withTitle: "Cancel")
                a.alertStyle = .warning

                a.beginSheetModal(for: self.view.window!, completionHandler: { (modalResponse) -> Void in
                    if modalResponse == NSApplication.ModalResponse.alertFirstButtonReturn {
                        
                            HelperFunctions.launchHelperApplication()
                            let wormhole = MMWormhole(applicationGroupIdentifier: GlobalVariables.sharedContainerID.rawValue, optionalDirectory: "wormhole")
                            wormhole.passMessageObject(NSString(string: "activateAppInPreferences"), identifier: "activateAppInPreferences")
            
                    }
                })
            #endif
        }

    }

    @IBAction func addRowTapped(_ sender: Any) {
        let dialog = NSOpenPanel()

        dialog.title = "Choose a directory where the FiScript should operate"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseDirectories = true
        dialog.canCreateDirectories = true
        dialog.canChooseFiles = false
        dialog.allowsMultipleSelection = false

        if dialog.runModal() == NSApplication.ModalResponse.OK {
            let result = dialog.url // Pathname of the file

            if result != nil {

                let path = result!.path

                preferences.pathsToAllowedDirectories.append(URL(string: path)!)
                tableView.reloadData()
                
                sendUpdatePathsToAllowedDirectories()
                
            }
        } else {
            // User clicked on "Cancel"
            return
        }

    }

    @IBAction func removeRowTapped(_ sender: Any) {
        let row = tableView.selectedRow

        if row == -1 {
            return
        }

        tableView.beginUpdates()

        preferences.pathsToAllowedDirectories.remove(at: row)
        tableView.removeRows(at: IndexSet(integer: row), withAnimation: .slideUp)
        
        tableView.endUpdates()

        sendUpdatePathsToAllowedDirectories()
        
    }


    @IBAction func OpenSettingsTapped(_ sender: Any) {
        NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Library/PreferencePanes/Extensions.prefPane"))
    }
    
    @IBAction func RestoreDefaultActions(_ sender: Any) {
        let context = persistentContainer.viewContext
        let request = Actions.createFetchRequest()
        let countOfDefaultActions = Int64(DefaultActions.numberOfDefaultActions)
        let idOfOldDefaultActions = stride(from: 0, to: countOfDefaultActions.toInt(), by: 1)
        
        do {
            var actions = try context.fetch(request)
            
            // removing old default actions
            for action in actions {
                if idOfOldDefaultActions.contains(action.id.toInt()) {
                    context.delete(action as NSManagedObject)
                }
            }
            
            actions = actions.filter { !idOfOldDefaultActions.contains($0.id.toInt()) }
            
            // incrementing the index of the current actions, to make space to the Default Actions
            for (index, action) in actions.enumerated() {
                action.index = Int64(index + countOfDefaultActions.toInt())
            }
            
            try context.save()
        } catch {
            fatalError()
        }
        
        DefaultActions.saveDefaultActions()
        
        let a = NSAlert()
        a.messageText = "Warning"
        a.informativeText = "Are you sure you want to restore the default actions? This will reset any changes to the default actions, but your actions will of course remain the same. The app has to restart to apply the changes."
        a.addButton(withTitle: "Restart")
        a.addButton(withTitle: "Cancel")
        a.alertStyle = .warning
        
        a.beginSheetModal(for: self.view.window!, completionHandler: { (modalResponse) -> Void in
            if modalResponse == NSApplication.ModalResponse.alertFirstButtonReturn {
                let url = URL(fileURLWithPath: Bundle.main.resourcePath!)
                let path = url.deletingLastPathComponent().deletingLastPathComponent().absoluteString
                let task = Process()
                task.launchPath = "/usr/bin/open"
                task.arguments = [path]
                task.launch()
                exit(0)
            }
        })
    }
    
}

extension GeneralViewController {
    
    fileprivate func sendUpdatePathsToAllowedDirectories() {

        let wormhole = MMWormhole(applicationGroupIdentifier: GlobalVariables.sharedContainerID.rawValue, optionalDirectory: "wormhole")
        wormhole.passMessageObject(NSString(string: "updatePathsToAllowedDirectories"), identifier: "pathsToAllowedDirectoriesHasChanged")
    }
    
    
}

extension GeneralViewController: NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        return preferences.pathsToAllowedDirectories.count
    }

}

extension GeneralViewController: NSTableViewDelegate {

    fileprivate enum CellIdentifiers {
        static let PathCell = "PathCellID"
    }

    // Initializes the tableView
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

        // checks if the tableView is 'Enabled'
        if tableColumn == tableView.tableColumns[0] {

            guard let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifiers.PathCell), owner: nil) as? NSTableCellView else {
                print("there was an error here: line 86 GeneralViewController")
                return nil
            }

            if preferences.pathsToAllowedDirectories.count != 0 {
                let item = preferences.pathsToAllowedDirectories[row]
                cell.textField?.stringValue = item.path

                // adds file:// to the url
                let filePathUrl = URL(fileURLWithPath: item.absoluteString)

                // check witch type the file is and adds a image to the cell
                if filePathUrl.absoluteString.range(of: "/Volumes/") != nil {
                    cell.imageView?.image = NSImage(named: NSImage.Name("ExternalDrive"))
                } else if filePathUrl.isDirectory {
                    cell.imageView?.image = NSImage(named: NSImage.Name("NSFolder"))
                }

            }

            return cell
        }
        return nil
    }
}




