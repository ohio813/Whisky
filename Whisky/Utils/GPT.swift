//
//  GPT.swift
//  Whisky
//
//  Created by Isaac Marovitz on 07/06/2023.
//

import Foundation
import AppKit

// GPT = Game Porting Toolkit
class GPT {
    static func isGPTInstalled() -> Bool {
        guard let resourcesURL = Bundle.main.resourceURL else {
            gptError(error: "Failed to get resource URL!")
            return false
        }

        let libFolder: URL = resourcesURL
            .appendingPathComponent("Libraries")
            .appendingPathComponent("Wine")
            .appendingPathComponent("lib")

        let externalFolder: URL = libFolder
            .appendingPathComponent("external")

        return FileManager.default.fileExists(atPath: externalFolder.path)
    }

    static func install(url: URL) {
        guard let resourcesURL = Bundle.main.resourceURL else {
            gptError(error: "Failed to get resource URL!")
            return
        }

        let libFolder: URL = resourcesURL
            .appendingPathComponent("Libraries")
            .appendingPathComponent("Wine")
            .appendingPathComponent("lib")

        do {
            let path = try Hdiutil.mount(url: url) + "/lib"

            if let pathEnumerator = FileManager.default.enumerator(atPath: path) {
                while let relativePath = pathEnumerator.nextObject() as? String {
                    let subItemAt = URL(fileURLWithPath: path).appendingPathComponent(relativePath).path
                    let subItemTo = libFolder.appendingPathComponent(relativePath).path

                    if isDir(atPath: subItemAt) {
                        if !isDir(atPath: subItemTo) {
                            try FileManager.default.createDirectory(atPath: subItemTo,
                                                                    withIntermediateDirectories: true)
                        }
                    } else {
                        if isFile(atPath: subItemTo) {
                            try FileManager.default.removeItem(atPath: subItemTo)
                        }

                        try FileManager.default.copyItem(atPath: subItemAt, toPath: subItemTo)
                    }
                }
                print("GPT Installed")
            } else {
                gptError(error: "Failed to create enumerator!")
            }

            try Hdiutil.unmount(path: path)
        } catch {
            print(error)
        }
    }

    static func gptError(error: String) {
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("gptalert.message", comment: "")
        alert.informativeText = error
        alert.alertStyle = .critical
        alert.addButton(withTitle: NSLocalizedString("button.ok", comment: ""))
        alert.runModal()
    }

    private static func isDir(atPath: String) -> Bool {
        var isDir: ObjCBool = false
        let exist = FileManager.default.fileExists(atPath: atPath, isDirectory: &isDir)
        return exist && isDir.boolValue
    }

    private static func isFile(atPath: String) -> Bool {
        var isDir: ObjCBool = false
        let exist = FileManager.default.fileExists(atPath: atPath, isDirectory: &isDir)
        return exist && !isDir.boolValue
    }
}
