//
//  AppliancePairingPresenter.swift
//
//
//  Created by Samir Tiouajni on 27/06/2024.
//

import Foundation
import GSMODApplianceSelectionKit

/// To delete with new TCA
public protocol AppliancePairingPresenter {
    func showPairingWifi(
        for selectedAppliance: SelectedAppliance,
        onFinished: @escaping () -> Void
    )
}
