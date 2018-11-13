//
//  Actions.swift
//  Common
//
//  Created by Mortennn on 22/10/2017.
//  Copyright © 2017 Mortennn. All rights reserved.
//

import Cocoa

// TO ADD NEW ACTIONS
// - increment countOfDefaultActions

fileprivate struct DefaultAction {
    let imageName: String
    let acceptedFileTypes: [String]
    let useOnFiles: Bool
    let useOnDirectories: Bool
    let actionDescription: String
    let confirmBeforeExecuting: Bool
    let enabled: Bool
    let getNotificationWhenExecusionHasFinished: Bool
    let id: Int64
    let index: Int64
    let script: String
    let shell: String
    let title: String
}

public class DefaultActions {

    public static func saveDefaultActions() {
        DefaultActions.defaultActions.forEach { (defaultAction) in
            
            let context = persistentContainer.viewContext
            let action = NSEntityDescription.insertNewObject(forEntityName: "Actions", into: context) as! Actions

            guard let image = NSImage(named: NSImage.Name(rawValue: defaultAction.imageName)),
                let imageData = image.png else {
                    fatalError("couldn't save images")
            }

            action.acceptedFileTypes = defaultAction.acceptedFileTypes
            action.useOnFiles = defaultAction.useOnFiles
            action.useOnDirectories = defaultAction.useOnDirectories
            action.actionDescription = defaultAction.actionDescription
            action.confirmBeforeExecuting = defaultAction.confirmBeforeExecuting
            action.enabled = defaultAction.enabled
            action.getNotificationWhenExecusionHasFinished = defaultAction.getNotificationWhenExecusionHasFinished
            action.imageData = imageData as NSData
            action.id = defaultAction.id
            action.index = defaultAction.index
            action.script = defaultAction.script
            action.shell = defaultAction.shell
            action.title = defaultAction.title
            
            do {
                try context.save()
            } catch {
                fatalError()
            }
        }
    }
    
    public static let numberOfDefaultActions:Int = {
        return DefaultActions.defaultActions.count
    }()

    fileprivate static let defaultActions = [
        DefaultAction(
            imageName: "Terminal",
            acceptedFileTypes: ["*"],
            useOnFiles: false,
            useOnDirectories: true,
            actionDescription: "Opens a new Terminal window in the selected directory.",
            confirmBeforeExecuting: false,
            enabled: false,
            getNotificationWhenExecusionHasFinished: false,
            id: 0,
            index: 0,
            script: """
            tell application "Terminal"
                if not (exists window 1) then reopen
                    activate
                    do script "cd " & $PATH & "; clear" in window 1
            end tell
            """,
            shell: "/usr/bin/env osascript",
            title: "Open Terminal Window"
        ),
        
        DefaultAction(
            imageName: "Terminal",
            acceptedFileTypes: [""],
            useOnFiles: false,
            useOnDirectories: true,
            actionDescription: """
            Opens a new Terminal tab in the current directory.
            """,
            confirmBeforeExecuting: false,
            enabled: false,
            getNotificationWhenExecusionHasFinished: false,
            id: 1,
            index: 1,
            script: """
            tell application "Terminal"
            if not (exists window 1) then reopen
                reopen
                activate
                delay 0.2
                tell application "System Events" to keystroke "t" using command down
                    do script "cd " & $PATH & "; clear" in window 1
            end tell
            """,
            shell: "/usr/bin/env osascript",
            title: "Open Terminal Tab"
        ),

        DefaultAction(
            imageName: "ITerm",
           acceptedFileTypes: ["*"],
            useOnFiles: false,
            useOnDirectories: true,
            actionDescription: "Opens a new iTerm window in the selected directory.",
            confirmBeforeExecuting: false,
            enabled: false,
            getNotificationWhenExecusionHasFinished: false,
            id: 2,
            index: 2,
            script: """
            if application "iTerm" is running then
            tell application "iTerm"
            create window with default profile
            activate
            tell the current window
            activate current session
            tell current session
            write text "cd " & $PATH & "; clear"
            end tell
            end tell
            end tell
            else
            activate application "iTerm"
            tell application "iTerm"
            tell current window
            tell current session
            write text "cd " & $PATH & "; clear"
            end tell
            end tell
            end tell
            end if
            """,
            shell: "/usr/bin/env osascript",
            title: "Open iTerm Window"
        ),

        DefaultAction(
            imageName: "ITerm",
            acceptedFileTypes: [""],
            useOnFiles: false,
            useOnDirectories: true,
            actionDescription: """
            Opens a new iTerm tab in the current directory.
            """,
            confirmBeforeExecuting: false,
            enabled: false,
            getNotificationWhenExecusionHasFinished: false,
            id: 3,
            index: 3,
            script: """
            tell application "iTerm"
                tell current window
                    create tab with default profile
                    activate
                    tell the current tab
                        activate current session
                        launch session "Default Session"
                        tell the last session
                            write text "cd " & $PATH & "; clear"
                        end tell
                    end tell
                end tell
            end tell
            """,
            shell: "/usr/bin/env osascript",
            title: "Open iTerm Tab"
        ),

        DefaultAction(
            imageName: "RunScript",
            acceptedFileTypes: ["sh"],
            useOnFiles: true,
            useOnDirectories: false,
            actionDescription: """
            Makes the selected shell script executable and then runs it.
            """,
            confirmBeforeExecuting: false,
            enabled: false,
            getNotificationWhenExecusionHasFinished: false,
            id: 4,
            index: 4,
            script: """
            chmod +x $PATH;
            sh $PATH;
            """,
            shell: "/bin/bash",
            title: "Run Script"
        ),
        
        DefaultAction(
            imageName: "CopyPath",
            acceptedFileTypes: ["*"],
            useOnFiles: true,
            useOnDirectories: true,
            actionDescription: "Copies the path of either the current directory or the selected file/directory.",
            confirmBeforeExecuting: false,
            enabled: false,
            getNotificationWhenExecusionHasFinished: false,
            id: 5,
            index: 5,
            script: """
            export LANG="en_US.UTF-8"; echo -n $PATH | pbcopy
            """,
            shell: "/bin/bash",
            title: "Copy Path"
        ),

        DefaultAction(
            imageName: "NewFile",
            acceptedFileTypes: [""],
            useOnFiles: false,
            useOnDirectories: true,
            actionDescription: """
            Creates a new file with the title "🤘emptyfile" (this positions the file at the top because of the emoji). You can then rename the file to the name you want and add an ending (e.g .docx or .html) to change the type of the file
            """,
            confirmBeforeExecuting: false,
            enabled: false,
            getNotificationWhenExecusionHasFinished: false,
            id: 6,
            index: 6,
            script: "touch 🤘emptyfile",
            shell: "/bin/bash",
            title: "New Empty File"
        ),

        DefaultAction(
            imageName: "ResizeOSXIcons",
            acceptedFileTypes: ["png"],
            useOnFiles: true,
            useOnDirectories: false,
            actionDescription: """
            Converts an PNG image to OSX ready icons (16x16, 32x32, 128x128, 256x256, and 512x512). If the image isn't big enough to be downscaled, the converted image will be upscaled (this should be avoided).
            """,
            confirmBeforeExecuting: false,
            enabled: false,
            getNotificationWhenExecusionHasFinished: false,
            id: 7,
            index: 7,
            script: """
            mkdir Icon.iconset
            cp $PATH Icon.iconset/Icon_512x512.png
            cp $PATH Icon.iconset/Icon_512x512@2x.png
            cp $PATH Icon.iconset/Icon_512x512@3x.png
            cp $PATH Icon.iconset/Icon_256x256.png
            cp $PATH Icon.iconset/Icon_256x256@2x.png
            cp $PATH Icon.iconset/Icon_256x256@3x.png
            cp $PATH Icon.iconset/Icon_128x128.png
            cp $PATH Icon.iconset/Icon_128x128@2x.png
            cp $PATH Icon.iconset/Icon_128x128@3x.png
            cp $PATH Icon.iconset/Icon_32x32.png
            cp $PATH Icon.iconset/Icon_32x32@2x.png
            cp $PATH Icon.iconset/Icon_32x32@3x.png
            cp $PATH Icon.iconset/Icon_16x16.png
            cp $PATH Icon.iconset/Icon_16x16@2x.png
            cp $PATH Icon.iconset/Icon_16x16@3x.png
            sips -Z 512 Icon.iconset/Icon_512x512.png
            sips -Z 1024 Icon.iconset/Icon_512x512@2x.png
            sips -Z 1536 Icon.iconset/Icon_512x512@3x.png
            sips -Z 256 Icon.iconset/Icon_256x256.png
            sips -Z 512 Icon.iconset/Icon_256x256@2x.png
            sips -Z 768 Icon.iconset/Icon_256x256@3x.png
            sips -Z 128 Icon.iconset/Icon_128x128.png
            sips -Z 256 Icon.iconset/Icon_128x128@2x.png
            sips -Z 384 Icon.iconset/Icon_128x128@3x.png
            sips -Z 32 Icon.iconset/Icon_32x32.png
            sips -Z 64 Icon.iconset/Icon_32x32@2x.png
            sips -Z 96 Icon.iconset/Icon_32x32@3x.png
            sips -Z 16 Icon.iconset/Icon_16x16.png
            sips -Z 32 Icon.iconset/Icon_16x16@2x.png
            sips -Z 48 Icon.iconset/Icon_16x16@3x.png
            """,
            shell: "/bin/bash",
            title: "Resize to macOS Icons"
        ),

        DefaultAction(
            imageName: "ResizeOSXIcons",
            acceptedFileTypes: ["png"],
            useOnFiles: true,
            useOnDirectories: false,
            actionDescription: """
            Converts a PNG image to IOS ready icons (16x16, 32x32, 128x128, 256x256, and 512x512). If the image isn't big enough to be downscaled, the converted image will be upscaled (this should be avoided).
            """,
            confirmBeforeExecuting: false,
            enabled: false,
            getNotificationWhenExecusionHasFinished: false,
            id: 8,
            index: 8,
            script: """
            mkdir Icon.iconset
            cp $PATH Icon.iconset/Icon_60x60@2x.png
            cp $PATH Icon.iconset/Icon_60x60@3x.png
            cp $PATH Icon.iconset/Icon_83.5x83.5@2x.png
            cp $PATH Icon.iconset/Icon_76x76@2x.png
            cp $PATH Icon.iconset/Icon_1024x1024@1x.png
            cp $PATH Icon.iconset/Icon_40x40@2x.png
            cp $PATH Icon.iconset/Icon_40x40@3x.png
            cp $PATH Icon.iconset/Icon_29x29@3x.png
            cp $PATH Icon.iconset/Icon_29x29@2x.png
            cp $PATH Icon.iconset/Icon_20x20@3x.png
            cp $PATH Icon.iconset/Icon_20x20@2x.png
            sips -Z 120 Icon.iconset/Icon_60x60@2x.png
            sips -Z 180 Icon.iconset/Icon_60x60@3x.png
            sips -Z 167 Icon.iconset/Icon_83.5x83.5@2x.png
            sips -Z 152 Icon.iconset/Icon_76x76@2x.png
            sips -Z 1024 Icon.iconset/Icon_1024x1024@1x.png
            sips -Z 120 Icon.iconset/Icon_40x40@2x.png
            sips -Z 80 Icon.iconset/Icon_40x40@3x.png
            sips -Z 87 Icon.iconset/Icon_29x29@3x.png
            sips -Z 58 Icon.iconset/Icon_29x29@2x.png
            sips -Z 60 Icon.iconset/Icon_20x20@3x.png
            sips -Z 40 Icon.iconset/Icon_20x20@2x.png
            """,
            shell: "/bin/bash",
            title: "Resize to iOS Icons"
        ),
        
        DefaultAction(
            imageName: "Sublime3",
            acceptedFileTypes: [""],
            useOnFiles: true,
            useOnDirectories: true,
            actionDescription: """
            Opens the selected directory/file in Sublime Text.
            """,
            confirmBeforeExecuting: false,
            enabled: false,
            getNotificationWhenExecusionHasFinished: false,
            id: 9,
            index: 9,
            script: "/Applications/Sublime\\ Text.app/Contents/SharedSupport/bin/subl $PATH",
            shell: "/bin/bash",
            title: "Open in Sublime Text"
        ),
        
        DefaultAction(
            imageName: "Atom",
            acceptedFileTypes: [""],
            useOnFiles: true,
            useOnDirectories: true,
            actionDescription: """
            Opens the selected directory/file in Atom.
            """,
            confirmBeforeExecuting: false,
            enabled: false,
            getNotificationWhenExecusionHasFinished: false,
            id: 10,
            index: 10,
            script: "/Applications/Atom.app/Contents/MacOS/Atom $PATH",
            shell: "/bin/bash",
            title: "Open in Atom"
        ),
        
        DefaultAction(
            imageName: "VSCode",
            acceptedFileTypes: [""],
            useOnFiles: true,
            useOnDirectories: true,
            actionDescription: """
            Opens the selected directory/file in VSCode.
            """,
            confirmBeforeExecuting: false,
            enabled: false,
            getNotificationWhenExecusionHasFinished: false,
            id: 11,
            index: 11,
            script: "/Applications/Visual\\ Studio\\ Code.app/Contents/Resources/app/bin/code $PATH",
            shell: "/bin/bash",
            title: "Open in VSCode"
        )
    ]

}
