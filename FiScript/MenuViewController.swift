//
//  MenuViewController.swift
//  FiScript
//
//  Created by Mortennn on 31/10/2017.
//  Copyright © 2017 Mortennn. All rights reserved.
//

import Cocoa
import Common

class MenuViewController: NSViewController {
    
    @IBOutlet weak var tableView: NSTableView!
    
    @IBOutlet weak var enableColumn: NSTableColumn!
    @IBOutlet weak var actionColumn: NSTableColumn!
    @IBOutlet var contextMenu: NSMenu!
    
    @IBOutlet var descriptionTextView: NSTextView!
    
    let preferences = Preferences.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // listeninig for load request
        NotificationCenter.default.addObserver(self, selector: #selector(loadTableView), name: NSNotification.Name(rawValue: "load"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(insertNewRow), name: NSNotification.Name(rawValue: "insertNewRow"), object: nil)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.target = self
        
        tableView.doubleAction = #selector(handleDoubleClick)
        
        tableView.registerForDraggedTypes([NSPasteboard.PasteboardType(rawValue: "private.table-row")])
        
        descriptionTextView.textStorage?.mutableString.setString("")
        
    }

    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        return self.tableView.clickedRow != -1
    }
    
    fileprivate func fetchActions() -> [Actions] {
        // Fetching actions for the tableview
        let context = persistentContainer.viewContext
        let request = Actions.createFetchRequest()
        
        do {
            let actions = try context.fetch(request)
            return actions
        } catch {
            fatalError()
        }
    }
    
    @objc func loadTableView() {
         self.tableView.reloadData()
    }
    
    @objc func insertNewRow() {
        self.tableView.beginUpdates()
        
        let actions = fetchActions()
        
        guard let numberOfRows = self.tableView?.numberOfRows else {
            fatalError()
        }
        
        let newAction = actions.filter { $0.index.toInt() == numberOfRows }.first!
        self.tableView.insertRows(at: IndexSet(integer: newAction.index.toInt()), withAnimation: .slideDown)
        
        self.tableView.endUpdates()
    }
    
    @objc func handleDoubleClick() {
        // checking if the double click was performed on a row
        if tableView.selectedRow != -1 {
            self.performSegue(withIdentifier: NSStoryboardSegue.Identifier("DoubleClick"), sender: nil)
        }
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier!.rawValue == "DoubleClick" {
            let destVC = segue.destinationController as! ModifyActionVC
            let clickedRow = self.tableView.clickedRow
            let selectedRow = self.tableView.selectedRow
            let row:Int = clickedRow == -1 ? selectedRow : clickedRow
            destVC.index = row
        }
    }
    
    @IBAction func addScriptTapped(_ sender: Any) {
        self.performSegue(withIdentifier: NSStoryboardSegue.Identifier("ModifyActionVC"), sender: nil)
    }
    
    @IBAction func deleteScriptTapped(_ sender: Any) {
        
        // if no path is selected, just return
        if self.tableView.selectedRow == -1 {
            return
        }
        
        // remove the deleted item from the model
        let row = tableView.selectedRow
        let context = persistentContainer.viewContext
        let request = Actions.createFetchRequest()
        request.predicate = NSPredicate(format: "index == \(row)")
    
        do {
            let action = try context.fetch(request).first!
            context.delete(action as NSManagedObject)
            
            try context.save()
        } catch {
            fatalError()
        }
        
        // remove the deleted item from the `NSTableView`
        self.tableView.removeRows(at: [row], withAnimation: .effectFade)
        
        saveActionIndexes()
        
    }
    
    @IBAction func EditTapped(_ sender: NSMenuItem) {
        self.performSegue(withIdentifier: NSStoryboardSegue.Identifier("DoubleClick"), sender: nil)
    }
    
    @IBAction func RemoveTapped(_ sender: NSMenuItem) {
        // if no path is selected, just return
        if self.tableView.clickedRow == -1 {
            return
        }
        
        // remove the deleted item from the model
        let row = tableView.clickedRow
        let context = persistentContainer.viewContext
        let request = Actions.createFetchRequest()
        request.predicate = NSPredicate(format: "index == \(row)")
        
        do {
            let action = try context.fetch(request).first!
            context.delete(action as NSManagedObject)
            
            try context.save()
        } catch {
            fatalError()
        }
        
        // remove the deleted item from the `NSTableView`
        self.tableView.removeRows(at: [row], withAnimation: .effectFade)
        
        saveActionIndexes()
    }
    
    // Saving new indexes
    fileprivate func saveActionIndexes() {
        guard let numberOfRows = enableColumn.tableView?.numberOfRows else {
            fatalError()
        }
        
        let rowIndexStride = stride(from: 0, to: numberOfRows, by: 1)
        
        for row in rowIndexStride {
            guard let cell = tableView.view(atColumn: 1, row: row, makeIfNecessary: false)?.subviews,
                let textfield = cell[1] as? NSTextField else {
                    fatalError()
            }
            
            let title = textfield.stringValue
            let context = persistentContainer.viewContext
            let request = Actions.createFetchRequest()
            request.predicate = NSPredicate(format: "title == \"\(title)\"")
            
            do {
                let action = try context.fetch(request).first!
                action.index = Int64(row)
                try context.save()
            } catch {
                fatalError()
            }
        }
    }
}

extension MenuViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        let actions = fetchActions()
        return actions.count
    }
    
}

extension MenuViewController: NSTableViewDelegate {
    
    fileprivate enum CellIdentifiers {
        static let EnableCell = "EnableCellID"
        static let ActionCell = "ActionCellID"
    }
    
    @objc func checkBoxTapped() {
        guard let numberOfRows = enableColumn.tableView?.numberOfRows else {
            fatalError()
        }
        
        let rowsStride = stride(from: 0, to: numberOfRows, by: 1)
        
        for row in rowsStride {
            guard let firstColumnAtRow = tableView.view(atColumn: 0, row: row, makeIfNecessary: false),
                let checkbox = firstColumnAtRow.subviews.first as? NSButton else {
                    return
            }
            
            // matches the actions by index and then saves the change
            let context = persistentContainer.viewContext
            let request = Actions.createFetchRequest()
            request.predicate = NSPredicate(format: "index == \"\(row)\"")
            
            do {
                let action = try context.fetch(request).first!
                action.enabled = (checkbox.isOn)
                try context.save()
            } catch {
                fatalError()
            }
        }
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        
        if tableView.selectedRow == -1 {
            descriptionTextView.textStorage?.mutableString.setString("")
            return
        }
        
        let actions = fetchActions()
        
        actions.forEach { (action) in
            
            let index = action.index.toInt()
            let description = action.actionDescription ?? ""
            
            if index == tableView.selectedRow {
                descriptionTextView.textStorage!.mutableString.setString(description)
            }
        }
    }
    
    // Initializes the tableView
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let actions = fetchActions()
        
        guard let action = actions.filter({ $0.index.toInt() == row }).first else {
            fatalError()
        }
        
        // checks if the tableView is Enable
        if tableColumn == tableView.tableColumns[0] {
            
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifiers.EnableCell), owner: nil) as? NSTableCellView {
                // getting the first and only element which is the checkbox button
                let checkBox = cell.subviews.first as! NSButton
                checkBox.target = self
                checkBox.action = #selector(checkBoxTapped)
                
                if action.enabled {
                    checkBox.state = .on
                } else {
                    checkBox.state = .off
                }
                
                checkBox.bezelStyle = .roundRect
                
                return cell
            }
            
            // checks if the tableView is Action
        } else if tableColumn == tableView.tableColumns[1] {
            
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifiers.ActionCell), owner: nil) as? NSTableCellView {
                cell.textField?.stringValue = action.title
                if let itemImage = action.imageData {
                    let itemImageData = itemImage as Data
                    cell.imageView!.image = NSImage(data: itemImageData)
                }
                
                return cell
            }
            
        }
        
        return nil
    }
    
    // MARK: TableView dragging ended
    func tableView(_ tableView: NSTableView, draggingSession session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {
        saveActionIndexes()
    }
    
    // MARK: functions for tableview dragging
    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        let item = NSPasteboardItem()
        item.setString(String(row), forType: NSPasteboard.PasteboardType(rawValue: "private.table-row"))
        return item
    }
    
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        if dropOperation == .above {
            return .move
        }
        return []
    }
    
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
        
        var oldIndexes = [Int]()
        info.enumerateDraggingItems(options: [], for: tableView, classes: [NSPasteboardItem.self], searchOptions: [:]) { arg0,arg1,arg2 in
            if let str = (arg0.item as! NSPasteboardItem).string(forType: NSPasteboard.PasteboardType(rawValue: "private.table-row")), let index = Int(str) {
                oldIndexes.append(index)
            }
        }
        
        var oldIndexOffset = 0
        var newIndexOffset = 0
        
        tableView.beginUpdates()
        for oldIndex in oldIndexes {
            if oldIndex < row {
                tableView.moveRow(at: oldIndex + oldIndexOffset, to: row - 1)
                oldIndexOffset -= 1
            } else {
                tableView.moveRow(at: oldIndex, to: row + newIndexOffset)
                newIndexOffset += 1
            }
        }
        tableView.endUpdates()
        
        return true
    }
}




