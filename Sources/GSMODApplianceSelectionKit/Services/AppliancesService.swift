//
//  AppliancesService.swift
//  GSMODApplianceSelectionKit
//
//  Created by Olivier Tavel on 25/06/2019.
//  Copyright © 2019 groupeseb. All rights reserved.
//

import Foundation



import RxSwift

public protocol AppliancesService {
    /// Get all appliances from all domains for specific market and language
    ///
    /// - Returns: Observable of Appliance array
    func getAppliances() -> Observable<[Appliance]>
    
    /// Get all appliances for a specific domain
    ///
    /// - Parameter domain: Specific domain
    /// - Returns: Observable of Appliance array
    func getAppliances(for domain: RawDomain) -> Observable<[Appliance]>
    
    func getAppliance(for applianceId: ApplianceId) -> Observable<Appliance>
    
    /// Invalidate appliances cache
    func invalidateCache()
}
