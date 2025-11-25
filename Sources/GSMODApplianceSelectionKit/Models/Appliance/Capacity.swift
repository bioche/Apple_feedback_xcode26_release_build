//
//  Capacity.swift
//  GSMODApplianceSelectionKit
//
//  Created by Olivier Tavel on 24/06/2019.
//  Copyright © 2019 groupeseb. All rights reserved.
//

import Foundation



public struct Capacity: Codable, Hashable {
    public var quantity: Double
    public var unit: String
    
    public init(quantity: Double, unit: String) {
        self.quantity = quantity
        self.unit = unit
    }
}

extension Capacity: CustomStringConvertible {
    public var description: String {
//        guard let language = GSBundle.language,
//            let region = GSBundle.region else {
//                return "\(quantity) l"
//        }
        let currentLocale = ""
        let measurement = Measurement(value: quantity, unit: UnitVolume.liters)
        let measurementFormatter = MeasurementFormatter()
        measurementFormatter.locale = Locale(identifier: currentLocale)
        measurementFormatter.unitOptions = .providedUnit
        measurementFormatter.numberFormatter.numberStyle = .decimal
        measurementFormatter.numberFormatter.usesSignificantDigits = true
        return measurementFormatter.string(from: measurement)
    }
}

extension Capacity: Stub {
    public static func stub() -> Capacity {
        return Capacity(quantity: 2, unit: "stublyboulga")
    }
}
