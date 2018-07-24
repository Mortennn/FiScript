//
//  ModifyActionVC.swift
//  FiScript
//
//  Created by Mortennn on 23/11/2017.
//  Copyright © 2017 Mortennn. All rights reserved.
//

import Cocoa
import CoreData
import Common

class ModifyActionVC: NSViewController {
    
    var index:Int?
    var action:Actions!

    @IBOutlet weak var AcceptedFileTypesTextField: NSTokenField!
    @IBOutlet weak var NameTextField: NSTextField!
    @IBOutlet weak var DescriptionTextView: NSTextView!
    @IBOutlet weak var ShellComboBox: NSComboBox!
    @IBOutlet weak var ScriptTextView: NSTextView!
    @IBOutlet weak var UseOnFilesCheckbox: NSButton!
    @IBOutlet weak var UseOnDirectoriesCheckbox: NSButton!
    @IBOutlet weak var ConfirmBeforeExecutingButton: NSButton!
    @IBOutlet weak var GetNotificationWhenExecusionHasFinishedButton: NSButton!
    @IBOutlet weak var ActionThumbnailImageView: NSImageView!
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        // Checking whether an action should be updated or created
        guard let unwrappedIndex = index else {
            return
        }
        
        let context = persistentContainer.viewContext
        let request = Actions.createFetchRequest()
        request.predicate = NSPredicate(format: "index == \(unwrappedIndex)")

        do {
            action = try context.fetch(request).first!
        } catch {
            fatalError("Coudn't fetch data, index doesn't exist")
        }

        NameTextField.stringValue = action.title
        DescriptionTextView.textStorage?.mutableString.setString(action.actionDescription ?? "")
        ShellComboBox.stringValue = action.shell
        ScriptTextView.textStorage?.mutableString.setString(action.script ?? "")
        
        UseOnFilesCheckbox.state = action.useOnFiles.stateValue()
        UseOnDirectoriesCheckbox.state = action.useOnDirectories.stateValue()
        ConfirmBeforeExecutingButton.state = action.confirmBeforeExecuting.stateValue()
        GetNotificationWhenExecusionHasFinishedButton.state = action.getNotificationWhenExecusionHasFinished.stateValue()

        if let acceptedFileTypes = action.acceptedFileTypes {
            if acceptedFileTypes.first != "" {
                AcceptedFileTypesTextField.objectValue = acceptedFileTypes
            }
        }

        if let imageNSData = action.imageData {
            let imageData = imageNSData as Data
            ActionThumbnailImageView.image = NSImage(data: imageData)
        }

    }
    
    @IBAction func saveTapped(_ sender: Any) {
        
        // Checking if all required fields are filled
        if NameTextField.stringValue.isEmpty { displayAlert(title: "Name"); return }
        if ShellComboBox.stringValue.isEmpty { displayAlert(title: "Shell"); return }
        if ScriptTextView.textStorage!.string.isEmpty { displayAlert(title: "Script"); return }
        
        let context = persistentContainer.viewContext
        let request = Actions.createFetchRequest()
        
        // an action should be updated
        if let unwrappedIndex = index {
            request.predicate = NSPredicate(format: "index == \(unwrappedIndex)")

            do {
                let action = try context.fetch(request).first!

                var imageData:NSData? = nil

                if let image = ActionThumbnailImageView.image {
                    imageData = NSData(data: image.png!)
                }
                
                action.useOnFiles = UseOnFilesCheckbox.isOn
                action.useOnDirectories = UseOnDirectoriesCheckbox.isOn
                action.acceptedFileTypes = AcceptedFileTypesTextField.objectValue as? [String]
                action.imageData = imageData ?? nil
                action.shell = ShellComboBox.stringValue
                action.title = NameTextField.stringValue
                action.actionDescription = DescriptionTextView.textStorage?.string
                action.confirmBeforeExecuting = ConfirmBeforeExecutingButton.isOn
                action.getNotificationWhenExecusionHasFinished = GetNotificationWhenExecusionHasFinishedButton.isOn
                action.script = ScriptTextView.textStorage?.string

                try context.save()
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
                
            } catch {
                fatalError("couldn't get action by id")
            }
        } else {
        // an new action should be created
            do {
                
                let actions = try context.fetch(request)
                
                // checking if name already exists
                if actions.filter({ $0.title! == NameTextField.stringValue }).count != 0 {
                    let a = NSAlert()
                    a.messageText = "Name already exist"
                    a.addButton(withTitle: "OK")
                    a.alertStyle = .critical
                    
                    a.beginSheetModal(for: self.view.window!, completionHandler: { (modalResponse) -> Void in
                        if modalResponse == NSApplication.ModalResponse.alertFirstButtonReturn {
                            return
                        }
                    })
                    
                    return
                }
                
                let newAction = NSEntityDescription.insertNewObject(forEntityName: "Actions", into: context) as! Actions
                let actionsCount = actions.count
                
                var imageData:NSData?
                
                if let image = ActionThumbnailImageView.image {
                    imageData = NSData(data: image.png!)
                }
                
                newAction.id = Int64(actionsCount)
                newAction.index = Int64(actionsCount)
                newAction.acceptedFileTypes = AcceptedFileTypesTextField.objectValue as? [String]
                newAction.useOnFiles = UseOnFilesCheckbox.isOn
                newAction.useOnDirectories = UseOnDirectoriesCheckbox.isOn
                newAction.imageData = imageData ?? nil
                newAction.shell = ShellComboBox.stringValue
                newAction.title = NameTextField.stringValue
                newAction.actionDescription = DescriptionTextView.textStorage?.string
                newAction.confirmBeforeExecuting = ConfirmBeforeExecutingButton.isOn
                newAction.getNotificationWhenExecusionHasFinished = GetNotificationWhenExecusionHasFinishedButton.isOn
                newAction.script = ScriptTextView.textStorage?.string
                newAction.enabled = true
                
                try context.save()
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "insertNewRow"), object: nil)
                
            } catch {
                fatalError("couln't fetch Actions")
            }
        }
        
        
        self.dismissViewController(self)
        
    }
    
    @IBAction func changeThumbnailTapped(_ sender: Any) {
        let dialog = NSOpenPanel();
        
        dialog.title = "Choose PNG image to be represented in the context menu";
        dialog.showsResizeIndicator = true;
        dialog.showsHiddenFiles = false;
        dialog.canChooseDirectories = false;
        dialog.canCreateDirectories = false;
        dialog.canChooseFiles = true
        dialog.allowsMultipleSelection = false;
        dialog.allowedFileTypes = ["png"]
        
        if dialog.runModal() == NSApplication.ModalResponse.OK {
            let result = dialog.url // Pathname of the file
            
            if result != nil {
                
                let path = result!.path
                
                let image = NSImage(contentsOf: URL(fileURLWithPath: path, isDirectory: false))!
                let resizedImage = image.resize(width: 16, 16)
                ActionThumbnailImageView.image = resizedImage
                
            }
        } else {
            // User clicked on "Cancel"
            return
        }
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.dismissViewController(self)
    }
    
    func displayAlert(title:String) {
        let a = NSAlert()
        a.messageText = "The \(title) field is required"
        a.addButton(withTitle: "OK")
        a.alertStyle = .warning
        
        a.beginSheetModal(for: self.view.window!, completionHandler: { (modalResponse) -> Void in
            if modalResponse == NSApplication.ModalResponse.alertFirstButtonReturn {
                return
            }
        })
    }
    
    
}






