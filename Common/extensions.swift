//
//  extensions.swift
//  Common
//
//  Created by Mortennn on 04/11/2017.
//  Copyright © 2017 Mortennn. All rights reserved.
//

import Foundation
import Cocoa

public extension URL {
    var isDirectory: Bool {
        let values = try? resourceValues(forKeys: [.isDirectoryKey])
        return values?.isDirectory ?? false
    }
}

public extension NSButton {
    public var isOn: Bool {
        if self.state == .on {
            return true
        } else {
            return false
        }
    }
}

public extension Bool {
    func stateValue() -> NSControl.StateValue {
        if self {
            return NSControl.StateValue.on
        } else {
            return NSControl.StateValue.off
        }
    }
}

public extension Int64 {
    public func toInt() -> Int {
        guard let newInt = Int(exactly: self) else {
            fatalError()
        }
        
        return newInt
    }
}

public extension URL {
    public func isFile() -> Bool {
        if self.absoluteString.last! != "/" {
            return true
        } else {
            return false
        }
    }
}

public extension NSBitmapImageRep {
    var png: Data? {
        return representation(using: .png, properties: [:])
    }
}

public extension Data {
    var bitmap: NSBitmapImageRep? {
        return NSBitmapImageRep(data: self)
    }
}

public extension NSImage {
    var png: Data? {
        return tiffRepresentation?.bitmap?.png
    }
}

public extension NSImage {
    func resize(width: CGFloat, _ height: CGFloat) -> NSImage {
        let img = NSImage(size: CGSize(width:width, height:height))
        
        img.lockFocus()
        let ctx = NSGraphicsContext.current
        ctx?.imageInterpolation = .high
        self.draw(in: NSMakeRect(0, 0, width, height), from: NSMakeRect(0, 0, size.width, size.height), operation: .copy, fraction: 1)
        img.unlockFocus()
        
        return img
    }
}

