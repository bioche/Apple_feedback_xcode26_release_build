//
//  ApplianceCapacityRealm.swift
//  GSMODApplianceSelectionKit
//
//  Created by Olivier Tavel on 06/08/2019.
//  Copyright © 2019 groupeseb. All rights reserved.
//

import Foundation

import RealmSwift

class ApplianceCapacityRealm: Object {
    @objc dynamic var quantity: Double = 0
    @objc dynamic var unit: String = ""
    @objc dynamic var key: String = ""
    
    override static func primaryKey() -> String? {
        return "key"
    }
    
    required convenience init(from capacity: Capacity) {
        self.init()
        self.quantity = capacity.quantity
        self.unit = capacity.unit
        self.key = "\(quantity) \(unit)"
    }
    
    func toCapacity() -> Capacity {
        return Capacity(quantity: quantity, unit: unit)
    }
}
