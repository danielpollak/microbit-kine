//
//  OverlayView.swift
//  MicrobitKine
//
//  Created by Daniel Pollak on 12/22/25.
//
//
import SwiftUI
import Combine

struct OverlayView: View {
    @ObservedObject var microbit: MicrobitSerial
    @EnvironmentObject var accelState: AccelState
    
    // Smoothed dot position
    @State private var dotX: CGFloat = 0
    @State private var dotY: CGFloat = 0
    
    // Target position from accelerometer
    @State private var targetX: CGFloat = 0
    @State private var targetY: CGFloat = 0
    
    
    // Timer for smoothing (~60 Hz)
    private let smoothingTimer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()

    // Smoothing factor (0=slow, 1=instant)
    private let alpha: CGFloat = 0.7

    var body: some View {
        GeometryReader { geo in
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            
            ZStack {
                Circle()
                    .fill(Color.red)
                    .frame(width: 20, height: 20)
                    .position(x: center.x + dotX, y: center.y + dotY)

                VStack {
                    Spacer()
                    Text("Micro:bit LED array should be facing you, pins facing up.")
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
            // Update target positions when new accel arrives
            .onReceive(accelState.$accel) { accel in
                targetX = -CGFloat(accel.x) * accelState.gain * 0.05
                targetY = CGFloat(accel.y) * accelState.gain * 0.05
            }
            // Smooth movement timer
            .onReceive(smoothingTimer) { _ in
                dotX += (targetX - dotX) * alpha
                dotY += (targetY - dotY) * alpha
            }
        }
        .edgesIgnoringSafeArea(.all)
        .background(Color.clear)
    }
}
