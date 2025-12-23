//
//  ContentView.swift
//  MicrobitKine
//
//  Created by Daniel Pollak on 12/20/25.
//

import SwiftUI

struct ContentView: View {

    @EnvironmentObject var accelState: AccelState
    @StateObject var microbit: MicrobitSerial

    init(accelState: AccelState) {
        _microbit = StateObject(wrappedValue: MicrobitSerial(accelState: accelState))
    }
    
    @State private var gain: Double = 1.0

    var body: some View {
        VStack(spacing: 12) {

            Text("micro:bit accel")
                .font(.headline)

            Text(microbit.accelText)
                .font(.system(.body, design: .monospaced))

            Slider(value: $gain, in: 0...5, step: 0.1) {
                Text("Gain")
            }

            Text(String(format: "Gain: %.2f", gain))
                .font(.caption)

        }
        .padding(16)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .frame(width: 260)
    }
}
