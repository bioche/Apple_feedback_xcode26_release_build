//
//  KitchenwareAvailabilityRealm.swift
//  GSMODApplianceSelectionKit
//
//  Created by Olivier Tavel on 25/06/2019.
//  Copyright © 2019 groupeseb. All rights reserved.
//

import Foundation



import RealmSwift

class KitchenwareAvailabilityRealm: Object {
    
    @objc dynamic var market: String = ""
    let compatibilities = List<KitchenwareCompatibilityRealm>()
    
    required convenience init(from kitchenwareAvailability: KitchenwareAvailability) {
        self.init()
        self.market = kitchenwareAvailability.market
        self.compatibilities.append(objectsIn: kitchenwareAvailability.compatibilities.map { KitchenwareCompatibilityRealm(from: $0) })
    }
    
    var kitchenwareAvailability: KitchenwareAvailability {
        let compatibilities: [KitchenwareCompatibility] = self.compatibilities.map({ $0.toKitchenwareCompatibility() })
        return KitchenwareAvailability(market: market, compatibilities: compatibilities)
    }
}

extension KitchenwareAvailabilityRealm: CascadeDeletable {
    var propertiesToCascadeDelete: [String] {
        return ["compatibilities"]
    }
}
