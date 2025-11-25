//
//  KitchenwareListViewState.swift
//
//
//  Created by Samir Tiouajni on 04/06/2024.
//


import SwiftUI

private typealias Localized = ApplianceSelectionLocalized.KitchenwareList

struct KitchenwareListViewState: Equatable {
    struct DeclarationButton: Equatable {
//        let state: AsyncButtonState
        let title: String
    }
    
    let inPackKitchenwareList: [KitchenwareCellModel]
    let complementaryKitchenwareList: [KitchenwareCellModel]
    let selectedApplianceName: String
    let disclosureType: DisclosureType
    
    let declarationButton: DeclarationButton?
}

extension KitchenwareListCore.State {
    var view: KitchenwareListViewState {
        let selectedApplianceName: String = {
            switch self.productState {
            case .existing(_, let selectedAppliance):
                return selectedAppliance?.appliance.name ?? ""
            case .pending(let appliance):
                return appliance.name
            }
        }()
        return .init(
            inPackKitchenwareList: kitchenwareCellModelList.filter { $0.isInPack },
            complementaryKitchenwareList: kitchenwareCellModelList.filter { !$0.isInPack },
            selectedApplianceName: selectedApplianceName,
            disclosureType: disclosureType,
            declarationButton: selectionPossible ? .init(
//                state: isLoading ? .inProgress : .enabled,
                title: Localized.declareButton(for: selectedKitchenwares.count)
            ) : nil
        )
    }
}
