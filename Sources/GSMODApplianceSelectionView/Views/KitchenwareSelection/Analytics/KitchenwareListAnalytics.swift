//
//  KitchenwareListAnalytics.swift
//
//
//  Created by Thibault POUJAT on 13/06/2022.
//

import Foundation


public struct KitchenwareSelectionAnalytics {
    public struct PageLoads {
        public static let sectionLabel = "KITCHENWARE_LIST"
        public static let elementType = "Kitchenware_List"
    }
    
    public struct ButtonTouch {
        public static let back = "list_accessory_back"
        public static let declaration = "kitchenware_list_declaration_validation"
    }
    
    public struct KitchenwareListEvent: GSEvent {
        public let eventType = "KITCHENWARE_LIST_CONSULT"
        public let parameterValues: [String: JSONObject]
        
        public init(id: String) {
            parameterValues = ["kitchenware_id": id]
        }
    }
}
