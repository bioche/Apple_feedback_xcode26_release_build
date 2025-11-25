//
//  AnalyticsConstants.swift
//  GSMODAppliance
//
//  Created by Hugo Saynac on 25/08/2017.
//  Copyright © 2017 groupeseb. All rights reserved.
//

import Foundation

enum Analytics {
    struct PageLoads {
        static let accountSectionLabel = "ACCOUNT"
        static let applianceSectionLabel = "APPLIANCE"
        static let applianceNotFoundSectionLabel = "ONBOARDING"
        
        static let applianceDetails = "Appliance_Details"
        static let applianceList = "Account_Appliance_List"
        static let families = "Account_Appliance_Family_List"
        static let selection = "Account_My_Appliance"
        static let kitchenware = "Account_Appliance_Accessories_List"
        
        static let applianceDomain = "Appliance_Domain_Selection"
        static let applianceFamilies = "Appliance_Family_Selection"
        static let applianceSelection = "Appliance_Product_Selection"
        static let applianceEdition = "Appliance_Rename_Product"
        static let applianceSynthesis = "Appliance_Synthesis"
        static let applianceNotFound = "Do_Not_Find_Product_Onboarding"
    }
    
    struct ButtonTouch {
        static let deleteProduct = "delete_product"
        static let renameProduct = "rename_product"
        static let pairedProduct = "pairing_from_product_detail"
    }
    
    struct ApplianceSynthesis {
        static let validation = "validate_product"
        static let applianceNotFound = "do_not_find_product_from_onboarding"
        static let savContactButton = "contact_sav_from_do_not_find_product_page"
        static let savContactBackButton = "arrow_back_from_do_not_find_product_page"
    }
    
    struct NicknameButtonTouch: GSEvent {
        var parameterValues: [String: JSONObject]
        var eventType: String = "APPLIANCE_NICKNAME"
        
        init(nickname: String) {
            parameterValues = ["nickname": nickname]
        }
    }
    
    struct ApplianceSelectedEvent: GSEvent {
        var parameterValues: [String: JSONObject]
        var eventType: String = "APPLIANCE_MY_APPLIANCE"
        
        enum SelectionType: String {
            case nearby = "nearby_selection"
            case manual = "full_list"
        }
        
        init(applianceId: String, applianceName: String, selectionType: SelectionType) {
            parameterValues = [
                "appliance_id": applianceId,
                "appliance_name": applianceName,
                "selection_from": selectionType.rawValue
            ]
        }
    }
    
    struct DomainSelectedEvent: GSEvent {
        var parameterValues: [String: JSONObject]
        var eventType: String = "APPLIANCE_DOMAIN"
        
        init(domain: String) {
            parameterValues = ["domain_key": domain]
        }
    }
    
    struct DomainSelectedEditEvent: GSEvent {
        var parameterValues: [String: JSONObject]
        var eventType: String = "EDIT_DOMAIN"
        
        init(domain: String) {
            parameterValues = ["domain_key": domain]
        }
    }
    
    struct FamilySelectedEvent: GSEvent {
        var parameterValues: [String: JSONObject]
        var eventType: String = "APPLIANCE_FAMILY"
        
        init(family: String) {
            parameterValues = ["appliance_family_id": family]
        }
    }
}

/// Represents an object directly convertible into JSON via JSONSerialization methods. Any structure or class that is used where a JSONObject is expected should succeed the `JSONSerialization.isValidJSONObject` test method.
public typealias JSONObject = Any

/// The protocol to be implemented by any custom event in modules & application that will be collected by `GSEventManager`
public protocol GSEvent {
    var parameterValues: [String: JSONObject] { get }
    var eventType: String { get }
    var isForSebana: Bool { get }
}

public extension GSEvent {
    var isForSebana: Bool { return true }
    
    func send() {

    }
}
