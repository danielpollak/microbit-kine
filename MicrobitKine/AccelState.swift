//
//  AccelState.swift
//  MicrobitKine
//
//  Created by Daniel Pollak on 12/22/25.
//

import Foundation
import Combine

struct Accel {
    var x: Double
    var y: Double
    var z: Double
}

class AccelState: ObservableObject {
    @Published var accel = Accel(x: 0, y: 0, z: 0)
    @Published var gain: Double = 1.0
}
