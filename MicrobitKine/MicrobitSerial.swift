//
//  MicrobitSerial.swift
//  MicrobitKine
//
//  Created by Daniel Pollak on 12/20/25.
//
import Foundation
import Combine
import ORSSerial


class MicrobitSerial: NSObject, ObservableObject, ORSSerialPortDelegate {
    @Published var parsedAccel: Accel? = nil
    @Published var accelText: String = "Waiting…"
    
    let accelState: AccelState

    private var serialPort: ORSSerialPort?
    private var buffer = ""

    init(accelState: AccelState) {
        self.accelState = accelState
        super.init()
        openSerial()
    }

    func openSerial() {
        let ports = ORSSerialPortManager.shared().availablePorts
        guard let port = ports.first(where: { $0.path.contains("usbmodem") }) else {
            accelText = "No micro:bit found"
            return
        }

        serialPort = port
        port.baudRate = 115200
        port.delegate = self
        port.open()
    }

    func serialPortWasRemovedFromSystem(_ serialPort: ORSSerialPort) {
        DispatchQueue.main.async {
            self.accelText = "micro:bit disconnected"
        }
        self.serialPort = nil
    }

    func serialPort(_ serialPort: ORSSerialPort, didReceive data: Data) {
        guard let chunk = String(data: data, encoding: .utf8) else { return }
        buffer += chunk

        let lines = buffer.components(separatedBy: "\n")
        buffer = lines.last ?? ""

        if lines.count > 1 {
            let line = lines[lines.count - 2].trimmingCharacters(in: .whitespacesAndNewlines)
            DispatchQueue.main.async {
                self.accelText = line

                // Try to parse numbers
                let parts = line.split(separator: ",").compactMap { Double($0) }
                if parts.count == 3 {
                    self.parsedAccel = Accel(x: parts[0], y: parts[1], z: parts[2])
                    self.accelState.accel = Accel(
                        x: parts[0],
                        y: parts[1],
                        z: parts[2]
                    )

                } else {
                    self.parsedAccel = nil
                }
            }
        }
    }
}
