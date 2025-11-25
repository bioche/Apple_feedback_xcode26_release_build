//
//  CachePolicy+Appliance.swift
//  GSMODApplianceSelectionKit
//
//  Created by Olivier Tavel on 07/08/2019.
//  Copyright © 2019 groupeseb. All rights reserved.
//

import Foundation



struct CachePolicyIds {
    private init() {}
    /// Id of cache policy for DCP appliances
    static let appliances = "AppliancesCachePolicyId"
    /// Id of cache policy for selected appliances by User
    static let selectedAppliances = "SelectedAppliancesCachePolicyId"
    /// Id of cache policy for DCP kitchenwares
    static let kitchenwares = "KitchenwaresCachePolicyId"
}

extension CachePolicy {
    static var appliances = CachePolicy(expirationTime: 24 * 60 * 60, refreshingTime: 60 * 60, numberOfElements: Int(INT_MAX), identifier: CachePolicyIds.appliances)
    
    static var selectedAppliances = CachePolicy(expirationTime: 24 * 60 * 60, refreshingTime: 60 * 60, numberOfElements: Int(INT_MAX), identifier: CachePolicyIds.selectedAppliances)
    
    static var kitchenwares = CachePolicy(expirationTime: 24 * 60 * 60, refreshingTime: 60 * 60, numberOfElements: Int(INT_MAX), identifier: CachePolicyIds.kitchenwares)
}
