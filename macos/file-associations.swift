import AppKit
import Foundation
import UniformTypeIdentifiers

// Bundle identifier -> content type (or "extensions") -> filename extensions.
typealias Associations = [String: [String: [String]]]

struct Association {
    let application: URL
    var declaredType: UTType?
    var samples: [URL]

    var typeMatches: Bool {
        guard let declaredType else { return true }
        return NSWorkspace.shared.urlForApplication(toOpen: declaredType) == application
    }
}

struct AssociationError: LocalizedError {
    let message: String
    var errorDescription: String? { message }
}

func fail(_ message: String) -> AssociationError {
    AssociationError(message: message)
}

func loadAssociations(from urls: [URL], samplesAt scratch: URL) throws -> [(String, Association)] {
    var associations: [String: Association] = [:]
    var seenExtensions = Set<String>()
    // Validate the entire config and find every application before changing anything.
    for url in urls {
        let config = try JSONDecoder().decode(Associations.self, from: Data(contentsOf: url))
        guard !config.isEmpty else { throw fail("The file-association config is empty.") }
        for (bundleID, types) in config {
            guard let application = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) else {
                throw fail("Application \(bundleID) is not installed. Install it before applying this config.")
            }
            guard !types.isEmpty else { throw fail("No content types configured for \(bundleID).") }
            for (identifier, extensions) in types {
                let declaredType = identifier == "extensions" ? nil : UTType(identifier)
                guard identifier == "extensions" || declaredType?.isDeclared == true else {
                    throw fail("Content type \(identifier) is not registered on this Mac.")
                }
                guard !extensions.isEmpty else { throw fail("No extensions configured for \(identifier).") }
                for ext in extensions {
                    guard ext.range(of: #"\A[a-zA-Z0-9_+#~-][a-zA-Z0-9._+#~-]*\z"#, options: .regularExpression) != nil,
                          !ext.hasSuffix("."),
                          seenExtensions.insert(ext.lowercased()).inserted else {
                        throw fail("Invalid or duplicate filename extension: \(ext)")
                    }
                    let sample = scratch.appendingPathComponent("sample.\(ext)")
                    let filenameType = UTType(filenameExtension: ext)
                    if (declaredType ?? filenameType)?.conforms(to: .directory) == true {
                        try FileManager.default.createDirectory(at: sample, withIntermediateDirectories: false)
                    } else {
                        try Data().write(to: sample)
                    }
                    guard let type = try sample.resourceValues(forKeys: [.contentTypeKey]).contentType,
                          type.tags[.filenameExtension]?.isEmpty == false else {
                        throw fail("No filename-specific content type found for .\(ext).")
                    }
                    if let declaredType, !type.conforms(to: declaredType) {
                        throw fail(".\(ext) resolves to \(type.identifier), expected \(identifier).")
                    }
                    let key = (declaredType ?? type).identifier
                    if let existing = associations[key], existing.application != application {
                        throw fail("Content type \(key) is assigned to multiple applications.")
                    }
                    var association = associations[key] ?? Association(
                        application: application, declaredType: declaredType, samples: [])
                    association.declaredType = association.declaredType ?? declaredType
                    association.samples.append(sample)
                    associations[key] = association
                }
            }
        }
    }
    return associations.sorted { $0.key < $1.key }
}

func apply(_ associations: [(String, Association)]) throws {
    var changed = 0
    for (identifier, association) in associations {
        let sample = association.samples.first {
            NSWorkspace.shared.urlForApplication(toOpen: $0) != association.application
        }
        if sample == nil && association.typeMatches {
            continue
        }
        let extensions = association.samples.map { "." + $0.pathExtension }.sorted().joined(separator: ", ")
        print("Updating \(extensions) → \(association.application.lastPathComponent)")
        var finished = false
        var failure: Error?
        let complete: (Error?) -> Void = { error in
            failure = error
            finished = true
        }
        if let declaredType = association.declaredType {
            NSWorkspace.shared.setDefaultApplication(at: association.application, toOpen: declaredType,
                                                      completion: complete)
        } else if let sample {
            NSWorkspace.shared.setDefaultApplication(at: association.application,
                                                      toOpenContentTypeOfFileAt: sample,
                                                      completion: complete)
        }
        let deadline = Date().addingTimeInterval(60)
        while !finished && Date() < deadline {
            RunLoop.current.run(until: Date().addingTimeInterval(0.05))
        }
        guard finished else { throw fail("Timed out updating \(extensions) (\(identifier)).") }
        if let failure { throw fail("Could not update \(extensions): \(failure.localizedDescription)") }
        changed += 1
    }
    print("Updated \(changed) content types; \(associations.count - changed) already matched.")
}

func check(_ associations: [(String, Association)]) throws {
    var mismatches = 0
    var extensionCount = 0
    for (identifier, association) in associations {
        if let type = association.declaredType,
           NSWorkspace.shared.urlForApplication(toOpen: type) != association.application {
            let current = NSWorkspace.shared.urlForApplication(toOpen: type)
            print("MISMATCH \(identifier): \(current?.lastPathComponent ?? "none") → expected \(association.application.lastPathComponent)")
            mismatches += 1
        }
        for sample in association.samples {
            let current = NSWorkspace.shared.urlForApplication(toOpen: sample)
            if current != association.application {
                print("MISMATCH .\(sample.pathExtension): \(current?.lastPathComponent ?? "none") → expected \(association.application.lastPathComponent)")
                mismatches += 1
            }
            extensionCount += 1
        }
    }
    guard mismatches == 0 else { throw fail("\(mismatches) checks failed. Rerun the same profile with --apply.") }
    print("Verified \(associations.count) content types and \(extensionCount) extensions.")
}

do {
    setvbuf(stdout, nil, _IOLBF, 0)
    guard CommandLine.arguments.count >= 3,
          ["--apply", "--check"].contains(CommandLine.arguments[1]) else {
        throw fail("Use bin/macos-file-associations [--check|--apply] [--setup].")
    }
    let scratch = FileManager.default.temporaryDirectory.appendingPathComponent("configs-file-associations-\(UUID().uuidString)")
    try FileManager.default.createDirectory(at: scratch, withIntermediateDirectories: false)
    defer { try? FileManager.default.removeItem(at: scratch) }
    let configURLs = CommandLine.arguments.dropFirst(2).map { URL(fileURLWithPath: $0) }
    let associations = try loadAssociations(from: configURLs, samplesAt: scratch)
    if CommandLine.arguments[1] == "--apply" {
        try apply(associations)
    } else {
        try check(associations)
    }
} catch {
    FileHandle.standardError.write(Data("File associations: \(error.localizedDescription)\n".utf8))
    exit(1)
}
