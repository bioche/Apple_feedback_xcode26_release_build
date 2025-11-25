//
//  KitchenwareCompatibilityRealm.swift
//  GSMODApplianceSelectionKit
//
//  Created by Olivier Tavel on 25/06/2019.
//  Copyright © 2019 groupeseb. All rights reserved.
//

import Foundation

import RealmSwift

class KitchenwareCompatibilityRealm: Object {
    @objc dynamic var applianceGroup: String = ""
    @objc dynamic var type: String = CompatibilityType.inPack.rawValue
    
    required convenience init(from kitchenwareCompatibility: KitchenwareCompatibility) {
        self.init()
        self.applianceGroup = kitchenwareCompatibility.applianceGroup
        self.type = kitchenwareCompatibility.type.rawValue
    }
    
    func toKitchenwareCompatibility() -> KitchenwareCompatibility {
        guard let compatibilityType = CompatibilityType(rawValue: type) else {
            fatalError("cannot convert realm value to real compatibility type with rawValue : \(type)")
        }
        return KitchenwareCompatibility(applianceGroup: applianceGroup, type: compatibilityType)
    }
}
