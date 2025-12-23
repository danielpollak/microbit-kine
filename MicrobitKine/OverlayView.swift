//
//  OverlayView.swift
//  MicrobitKine
//
//  Created by Daniel Pollak on 12/22/25.
//

import SwiftUI
struct OverlayView: View {
    @ObservedObject var microbit: MicrobitSerial
    @EnvironmentObject var accelState: AccelState

    var body: some View {
        GeometryReader { geo in
            let center = CGPoint(x: geo.size.width / 2,
                                 y: geo.size.height / 2)

            let dx = accelState.accel.x * accelState.gain * 0.05
            let dy = -accelState.accel.y * accelState.gain * 0.05

            ZStack {
                Circle()
                    .fill(Color.red)
                    .frame(width: 20, height: 20)
                    .position(x: center.x + dx,
                              y: center.y + dy)

                VStack {
                    Spacer()
                    Text(microbit.accelText)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.white)
                        .background(Color.black.opacity(0.6))
                        .padding()

                    Slider(value: $accelState.gain, in: 0...5)
                        .frame(width: 200)
                        .padding()
                }
            }
        }
    }
}
