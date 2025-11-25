//
//  ApplianceErrors.swift
//  GSMODApplianceSelectionKit
//
//  Created by Olivier Tavel on 14/08/2019.
//  Copyright © 2019 groupeseb. All rights reserved.
//

import Foundation

public enum SelectedApplianceError: Error {
    case applianceGroupMissing(applianceId: ApplianceId)
    case applianceNotFound(applianceId: ApplianceId)
    case productsNotFound
    case productNotFound(productId: ProductId)
}

public enum ApplianceError: Error {
    case appliancesNotFound
    case applianceNotFound(applianceId: ApplianceId)
    case kitchenwaresNotFound(applianceGroup: String)
    case kitchenwareNotFound(key: String)
}
