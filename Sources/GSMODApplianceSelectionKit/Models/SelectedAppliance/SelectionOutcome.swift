//
//  SelectionRequestAnswer.swift
//  GSMODApplianceSelectionView
//
//  Created by Eric Blachère on 19/11/2019.
//  Copyright © 2019 groupeseb. All rights reserved.
//

import Foundation

/// The result of the user interaction with the UI
public enum SelectionOutcome: Equatable {
    /// The user chose an appliance, the client app created a product & it was persisted in module
    case createdProduct(SelectedAppliance)
    /// The user chose an appliance but the product wasn't created --> no persistence
    case requested(Appliance, nickname: String?)
    
    /// Gives the appliance selected or requested
    public var appliance: Appliance {
        switch self {
        case .requested(let appliance, _): appliance
        case .createdProduct(let selectedAppliance): selectedAppliance.appliance
        }
    }
    
    public var selectedAppliance: SelectedAppliance? {
        switch self {
        case .createdProduct(let selected): selected
        case .requested: nil
        }
    }
}
