//
//  MicrobitSerial.swift
//  MicrobitKine
//
//  Created by Daniel Pollak on 12/20/25.
//
import Foundation
import Combine
import ORSSerial

class MicrobitSerial: NSObject, ObservableObject {
    let accelState: AccelState
    @Published var accelText: String = "Waiting…"

    private var serialPort: ORSSerialPort?
    private var buffer = ""
    
    //debugging
    private var lastPacketTime: TimeInterval = 0
//    private var lastUIUpdate: TimeInterval = 0
    private var lastUIUpdate: TimeInterval? = nil



    init(accelState:AccelState) {
        self.accelState = accelState
        super.init()
        openSerial()
    }

    func openSerial() {
        let ports = ORSSerialPortManager.shared().availablePorts
        print("Detected serial ports:")
        for p in ports {
            print("  - \(p.name) (\(p.path))")
        }

        guard let port = ports.first(where: { $0.path.contains("usbmodem") }) else {
            DispatchQueue.main.async {
                self.accelText = "No micro:bit found"
            }
            return
        }

        serialPort = port
        port.baudRate = 115200
        port.delegate = self
        port.open()
    }
}

// MARK: - ORSSerialPortDelegate

extension MicrobitSerial: ORSSerialPortDelegate {

    func serialPortWasOpened(_ serialPort: ORSSerialPort) {
        DispatchQueue.main.async {
            self.accelText = "micro:bit connected"
        }
        print("Serial port opened:", serialPort.path)
    }

    func serialPortWasRemovedFromSystem(_ serialPort: ORSSerialPort) {
        DispatchQueue.main.async {
            self.accelText = "micro:bit disconnected"
        }
        self.serialPort = nil
    }



    func serialPort(_ serialPort: ORSSerialPort, didReceive data: Data) {
        let now = Date().timeIntervalSince1970
        let dt = now - lastPacketTime
        lastPacketTime = now
        print("Packet received, dt = \(dt)s, bytes = \(data.count)")
        
        // existing buf
        guard let chunk = String(data: data, encoding: .utf8) else { return }
        buffer += chunk

        // Split buffer into numbers
        var numbers = buffer.split(separator: ",").map { String($0) }

        // Process complete triples
        while numbers.count >= 3 {
            if let x = Double(numbers[0]),
               let y = Double(numbers[1]),
               let z = Double(numbers[2]) {

                // --- Measure UI update rate ---
                DispatchQueue.main.async {
                    let now = Date().timeIntervalSince1970
                    let dt = now - (self.lastUIUpdate ?? now)
                    self.lastUIUpdate = now
                    print("UI updated, dt = \(dt)s, accel = \(x),\(y),\(z)")

                    self.accelState.accel = Accel(x: x, y: y, z: z)
                    self.accelText = "\(x),\(y),\(z)"   // <-- update this property
                }

                // -----------------------------
            }

            // Remove the processed numbers
            numbers.removeFirst(3)
        }

        // Save leftovers back to buffer
        buffer = numbers.joined(separator: ",")
    }


//    func serialPort(_ serialPort: ORSSerialPort,
//                    didReceive data: Data) {
//        
//        guard let chunk = String(data: data, encoding: .utf8) else { return }
//        buffer += chunk
//
//        while let newline = buffer.firstIndex(of: "\n") {
//            let line = String(buffer[..<newline])
//            buffer.removeSubrange(...newline)
//            print("RAW:", line)
//            DispatchQueue.main.async {
//                self.accelText = line
//            }
//
//            let parts = line.split(separator: ",")
//
//            guard parts.count >= 3,
//                  let x = Double(parts[0]),
//                  let y = Double(parts[1]),
//                  let z = Double(parts[2]) else { continue }
//
//            DispatchQueue.main.async {
//                self.accelState.accel = Accel(x: x, y: y, z: z)
//            }
//        }
//    }


    func serialPort(_ serialPort: ORSSerialPort,
                    didEncounterError error: Error) {
        print("Serial error:", error)
    }
}

