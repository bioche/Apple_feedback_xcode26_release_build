//
//  KitchenwareAvailability.swift
//  GSMODApplianceSelectionKit
//
//  Created by Olivier Tavel on 25/06/2019.
//  Copyright © 2019 groupeseb. All rights reserved.
//

import Foundation

import RealmSwift

public struct KitchenwareAvailability: Codable {
    public var market: String
    public var compatibilities: [KitchenwareCompatibility]
}

extension KitchenwareAvailability {
    func toRealmObject() -> KitchenwareAvailabilityRealm {
        return KitchenwareAvailabilityRealm(from: self)
    }
}
