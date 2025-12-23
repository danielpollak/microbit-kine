//
//  AppDelegate.swift
//  MicrobitKine
//
//  Created by Daniel Pollak on 12/20/25.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ notification: Notification) {
        guard let window = NSApplication.shared.windows.first else { return }

        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = .floating
        window.collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary
        ]
        window.setFrame(NSRect(x: 100, y: 100, width: 300, height: 200),
                        display: true)
    }
}
