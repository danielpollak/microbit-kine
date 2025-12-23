//
//  MicrobitKineApp.swift
//  MicrobitKine
//
//  Created by Daniel Pollak on 12/20/25.
//

import SwiftUI
import AppKit

@main
struct MicrobitKineApp: App {

    @StateObject var accelState = AccelState()
    @StateObject var microbit: MicrobitSerial

    init() {
        let state = AccelState()
        _accelState = StateObject(wrappedValue: state)
        _microbit = StateObject(wrappedValue: MicrobitSerial(accelState: state))
    }

    var body: some Scene {
        WindowGroup {
            OverlayView(microbit: microbit)
                .environmentObject(accelState)
                .background(Color.clear)
                .onAppear {
                    if let window = NSApplication.shared.windows.first {
                        NSWindow.makeOverlay(window)
                    }
                }
        }
        .windowStyle(.plain)
    }
}


extension NSWindow {
    static func makeOverlay(_ window: NSWindow) {
        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.ignoresMouseEvents = false
    }
}
