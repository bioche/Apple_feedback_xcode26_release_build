//
//  KitchenwareService.swift
//  GSMODApplianceSelectionKit
//
//  Created by Olivier Tavel on 25/06/2019.
//  Copyright © 2019 groupeseb. All rights reserved.
//

import Foundation




import RxSwift

public protocol KitchenwaresService {
    /// Get all kitchenwares for an specific applianceGroup
    ///
    /// - Parameter applianceGroup: Specific ApplianceGroup
    /// - Returns: Observable of Kitchenware array
    func getKitchenwares(applianceGroup: String) -> Observable<[Kitchenware]>
    
    /// Invalidate kitwhenwares cache
    func invalidateCache()
}
