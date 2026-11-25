import AppKit
import CryptoKit
import Darwin
import Foundation

struct Browser {
    let name: String
    let bundleIdentifier: String
    let bundle: URL
    let artwork: String
}

func digest(_ data: Data) -> String {
    SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
}

func iconFingerprint(for bundle: URL, artwork: Data) -> String? {
    // Finder stores the custom-icon flag in the high byte of the Finder flags.
    var finderInfo = [UInt8](repeating: 0, count: 32)
    let count = getxattr(bundle.path, "com.apple.FinderInfo", &finderInfo, finderInfo.count, 0, 0)
    guard count == finderInfo.count, finderInfo[8] & 0x04 != 0 else { return nil }

    let resourceFork = bundle.appendingPathComponent("Icon\r/..namedfork/rsrc")
    guard let icon = try? Data(contentsOf: resourceFork), !icon.isEmpty else { return nil }
    return "\(digest(artwork)) \(digest(icon))"
}

let arguments = CommandLine.arguments
guard arguments.count == 4 else { exit(2) }
let mode = arguments[1]
let configs = URL(fileURLWithPath: arguments[2], isDirectory: true)
let cache = URL(fileURLWithPath: arguments[3], isDirectory: true)
let files = FileManager.default
let home = files.homeDirectoryForCurrentUser
let label = "local.configs.helium-icons"

if mode == "--write-agent" {
    let agents = home.appendingPathComponent("Library/LaunchAgents", isDirectory: true)
    let logs = home.appendingPathComponent("Library/Logs", isDirectory: true)
    try files.createDirectory(at: agents, withIntermediateDirectories: true)
    try files.createDirectory(at: logs, withIntermediateDirectories: true)
    let properties: [String: Any] = [
        "Label": label,
        "ProgramArguments": [configs.appendingPathComponent("bin/macos-helium-icons").path, "--repair"],
        "RunAtLoad": true,
        "StartInterval": 300,
        "StandardErrorPath": logs.appendingPathComponent("configs-helium-icons.log").path,
    ]
    let plist = try PropertyListSerialization.data(fromPropertyList: properties, format: .xml, options: 0)
    try plist.write(to: agents.appendingPathComponent("\(label).plist"), options: .atomic)
    exit(0)
}

let lock = open(cache.appendingPathComponent("lock").path, O_CREAT | O_CLOEXEC | O_RDWR, 0o600)
guard lock >= 0, flock(lock, LOCK_EX) == 0 else {
    fputs("Could not lock the Helium icon cache.\n", stderr)
    exit(1)
}

let browsers = [
    Browser(name: "Helium Personal", bundleIdentifier: "net.imput.helium",
            bundle: URL(fileURLWithPath: "/Applications/Helium.app"),
            artwork: "helium-personal.png"),
    Browser(name: "Helium Work", bundleIdentifier: "local.fran.helium.work",
            bundle: home.appendingPathComponent("Applications/Helium Work.app"),
            artwork: "helium-work.png"),
]

let artworkDirectory = configs.appendingPathComponent("macos/icons", isDirectory: true)
var success = true
for browser in browsers {
    guard files.fileExists(atPath: browser.bundle.path) else {
        if mode != "--repair" {
            fputs("\(browser.name): app missing at \(browser.bundle.path)\n", stderr)
            success = false
        }
        continue
    }
    guard Bundle(url: browser.bundle)?.bundleIdentifier == browser.bundleIdentifier else {
        fputs("\(browser.name): unexpected bundle ID at \(browser.bundle.path)\n", stderr)
        success = false
        continue
    }

    do {
        let artwork = try Data(contentsOf: artworkDirectory.appendingPathComponent(browser.artwork))
        let receipt = cache.appendingPathComponent(browser.bundleIdentifier)
        let current = iconFingerprint(for: browser.bundle, artwork: artwork)
        let saved = try? String(contentsOf: receipt, encoding: .utf8)
        if let current, current == saved {
            if mode != "--repair" { print("\(browser.name): icon verified") }
            continue
        }
        if mode == "--check" {
            fputs("\(browser.name): configured icon is missing or has changed\n", stderr)
            success = false
            continue
        }
        guard let image = NSImage(data: artwork),
              NSWorkspace.shared.setIcon(image, forFile: browser.bundle.path, options: []),
              let installed = iconFingerprint(for: browser.bundle, artwork: artwork) else {
            fputs("\(browser.name): macOS did not apply the icon. Check App Management permissions.\n", stderr)
            success = false
            continue
        }
        try installed.write(to: receipt, atomically: true, encoding: .utf8)
        if mode != "--repair" { print("\(browser.name): icon applied") }
    } catch {
        fputs("\(browser.name): \(error.localizedDescription)\n", stderr)
        success = false
    }
}
close(lock)
exit(success ? 0 : 1)
