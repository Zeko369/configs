import AppKit
import Foundation
import UniformTypeIdentifiers

// Bundle identifier -> content type -> filename extensions to verify.
typealias Associations = [String: [String: [String]]]

struct Association {
    let application: URL
    let contentType: UTType
    let extensions: [String]
}

struct AssociationError: LocalizedError {
    let message: String
    var errorDescription: String? { message }
}

func fail(_ message: String) -> AssociationError {
    AssociationError(message: message)
}

func loadAssociations(from url: URL) throws -> [Association] {
    let config = try JSONDecoder().decode(Associations.self, from: Data(contentsOf: url))
    guard !config.isEmpty else { throw fail("The file-association config is empty.") }
    var associations: [Association] = []
    var seenTypes = Set<String>()
    var seenExtensions = Set<String>()
    // Validate the entire config and find every application before changing anything.
    for bundleID in config.keys.sorted() {
        guard let application = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) else {
            throw fail("Application \(bundleID) is not installed. Install it before applying this config.")
        }
        let types = config[bundleID]!
        guard !types.isEmpty else { throw fail("No content types configured for \(bundleID).") }
        for identifier in types.keys.sorted() {
            guard seenTypes.insert(identifier).inserted else {
                throw fail("Content type \(identifier) is assigned to multiple applications.")
            }
            guard let contentType = UTType(identifier), contentType.isDeclared else {
                throw fail("Content type \(identifier) is not registered on this Mac.")
            }
            let extensions = types[identifier]!
            guard !extensions.isEmpty else { throw fail("No extensions configured for \(identifier).") }
            for ext in extensions {
                guard !ext.isEmpty, !ext.hasPrefix("."), !ext.contains("/"),
                      seenExtensions.insert(ext.lowercased()).inserted else {
                    throw fail("Invalid or duplicate filename extension: \(ext)")
                }
                guard UTType(filenameExtension: ext)?.conforms(to: contentType) == true else {
                    throw fail(".\(ext) does not resolve to \(identifier) on this Mac; update the config.")
                }
            }
            associations.append(Association(application: application, contentType: contentType, extensions: extensions))
        }
    }
    return associations
}

func apply(_ associations: [Association]) throws {
    var changed = 0
    for association in associations {
        if NSWorkspace.shared.urlForApplication(toOpen: association.contentType) == association.application {
            continue
        }
        var finished = false
        var failure: Error?
        // The deprecated LSSetDefaultRoleHandlerForContentType can report success
        // without persisting a change. Wait for the modern API's completion instead.
        NSWorkspace.shared.setDefaultApplication(at: association.application, toOpen: association.contentType) { error in
            failure = error
            finished = true
        }
        let deadline = Date().addingTimeInterval(60)
        while !finished && Date() < deadline {
            RunLoop.current.run(until: Date().addingTimeInterval(0.05))
        }
        guard finished else { throw fail("Timed out updating \(association.contentType.identifier).") }
        if let failure { throw failure }
        changed += 1
        print("Applied \(association.contentType.identifier) → \(association.application.lastPathComponent)")
    }
    print("Updated \(changed) content types; \(associations.count - changed) already matched.")
}

func check(_ associations: [Association]) throws {
    let scratch = FileManager.default.temporaryDirectory.appendingPathComponent("configs-file-associations-\(UUID().uuidString)")
    try FileManager.default.createDirectory(at: scratch, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: scratch) }
    var mismatches = 0
    var extensionCount = 0
    for association in associations {
        let current = NSWorkspace.shared.urlForApplication(toOpen: association.contentType)
        if current != association.application {
            print("MISMATCH \(association.contentType.identifier): \(current?.lastPathComponent ?? "none") → expected \(association.application.lastPathComponent)")
            mismatches += 1
        }
        for ext in association.extensions {
            let sample = scratch.appendingPathComponent("sample.\(ext)")
            if association.contentType.conforms(to: .directory) {
                try FileManager.default.createDirectory(at: sample, withIntermediateDirectories: false)
            } else {
                try Data().write(to: sample)
            }
            let current = NSWorkspace.shared.urlForApplication(toOpen: sample)
            if current != association.application {
                print("MISMATCH .\(ext): \(current?.lastPathComponent ?? "none") → expected \(association.application.lastPathComponent)")
                mismatches += 1
            }
            extensionCount += 1
        }
    }
    guard mismatches == 0 else { throw fail("\(mismatches) checks failed. Run bin/macos-file-associations --apply to restore the configured defaults.") }
    print("Verified \(associations.count) content types and \(extensionCount) extensions.")
}

do {
    guard CommandLine.arguments.count == 3,
          ["--apply", "--check"].contains(CommandLine.arguments[2]) else {
        throw fail("Use bin/macos-file-associations [--check|--apply].")
    }
    let configURL = URL(fileURLWithPath: CommandLine.arguments[1])
    let associations = try loadAssociations(from: configURL)
    if CommandLine.arguments[2] == "--apply" {
        try apply(associations)
    } else {
        try check(associations)
    }
} catch {
    FileHandle.standardError.write(Data("File associations: \(error.localizedDescription)\n".utf8))
    exit(1)
}
