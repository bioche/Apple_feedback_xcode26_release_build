//
//  KitchenwareCompatibility.swift
//  GSMODApplianceSelectionKit
//
//  Created by Olivier Tavel on 25/06/2019.
//  Copyright © 2019 groupeseb. All rights reserved.
//

import Foundation

public enum CompatibilityType: String {
    case inPack = "IN_PACK"
    case outOfPack = "OUT_OF_PACK"
}

extension CompatibilityType: Codable {}

public struct KitchenwareCompatibility: Codable {
    public var applianceGroup: String
    public var type: CompatibilityType
}

extension KitchenwareCompatibility {
    func toRealmObject() -> KitchenwareCompatibilityRealm {
        return KitchenwareCompatibilityRealm(from: self)
    }
}
