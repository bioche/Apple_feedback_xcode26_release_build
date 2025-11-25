//
//  CategorySelectionCore+Models.swift
//
//
//  Created by Samir Tiouajni on 25/06/2024.
//

import GSMODApplianceSelectionKit

extension CategorySelectionCore {
    public struct Product: Hashable {
        public let productId: String
        public let availableKitchenwares: Int
        public let selectedKitchenwares: Int
        public let selectedAppliance: SelectedAppliance
        
        public var kitchenwares: String? {
            if selectedKitchenwares > 1 {
                return String(format: String(gsLocalized: "applianceselection_categoryselection_product_kitchenwares_plural"), selectedKitchenwares)
            } else if selectedKitchenwares == 1 {
                return String(gsLocalized: "applianceselection_categoryselection_product_kitchenwares_singular")
            } else if availableKitchenwares > 0 {
                return String(gsLocalized: "applianceselection_categoryselection_product_kitchenwares_none")
            }
            return nil
        }
    }

}
