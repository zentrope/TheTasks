//
//  SavePanel.swift
//  TheTasks
//
//  Created by Keith Irwin on 6/26/22.
//

import Cocoa
import OSLog

fileprivate let log = Logger("AppKit")

struct AppKit {

    static func save(text: String, toName filename: String) throws {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.commaSeparatedText]
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = false
        savePanel.allowsOtherFileTypes = false
        savePanel.title = "Save your text"
        savePanel.message = "Choose a folder and a name to store your text."
        savePanel.nameFieldLabel = "File name:"
        savePanel.nameFieldStringValue = filename
        let response = savePanel.runModal()
        guard response == .OK, let url = savePanel.url else { return }
        try text.write(toFile: url.path, atomically: true, encoding: .utf8)
        FileManager.default.maybeHideExtension(atPath: url.path)
        log.info("Data exported to \(url).")
    }
}
