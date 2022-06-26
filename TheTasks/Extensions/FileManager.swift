//
//  FileManager.swift
//  TheTasks
//
//  Created by Keith Irwin on 6/26/22.
//

import Foundation
import OSLog

fileprivate let log = Logger("FileManager")

extension FileManager {

    /// Attempt to hide the extension of the file at path, logging an error if it fails because we don't care that much.
    func maybeHideExtension(atPath path: String)  {
        do {
            try setAttributes([.extensionHidden : true], ofItemAtPath: path)
        } catch {
            log.error("Unable to hide extension for '\(path)': \(error.localizedDescription).")            
        }
    }
}
