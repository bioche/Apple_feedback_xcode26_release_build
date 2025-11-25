//
//  ApplianceListViewState.swift
//  GSMODApplianceSelection
//
//  Created by Thibault POUJAT on 12/09/2025.
//

import Foundation
import GSMODApplianceSelectionKit

struct ApplianceListViewState: Equatable {
    let appliances: [Appliance]
    let nearbyAppliances: [Appliance]
    let shouldAutoDetectAppliances: Bool
}

extension ApplianceListCore.State {
    var applianceListView: ApplianceListViewState {
        .init(
            appliances: appliances,
            nearbyAppliances: nearbyAppliances,
            shouldAutoDetectAppliances: shouldAutoDetectAppliances
        )
    }
}
