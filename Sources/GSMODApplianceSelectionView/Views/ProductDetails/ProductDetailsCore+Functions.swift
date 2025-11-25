//
//  ProductDetailsCore+Functions.swift
//
//
//  Created by Samir Tiouajni on 01/06/2024.
//

import RxComposableArchitecture
import GSMODApplianceSelectionKit

extension ProductDetailsCore {
    
    static func setApplianceNickname(state: inout ProductDetailsCore.State) {
        // If nickname is empty, we apply the appliance official name
        if let appliance = state.selectedAppliance, state.applianceNickname.trimmingCharacters(in: .whitespaces).isEmpty {
            state.applianceNickname = appliance.appliance.name
            state.selectedAppliance?.nickname = appliance.appliance.name
        } else {
            state.applianceNickname = state.applianceNickname.trimmingCharacters(in: .whitespaces)
            state.selectedAppliance?.nickname = state.applianceNickname.trimmingCharacters(in: .whitespaces)
        }
    }
    
    static func getApplianceInfos(
        _ selectedAppliance: SelectedAppliance,
        _ customInfos: [ProductDetailCustomInfo],
        applianceInformations: inout [String]
    ) {
        
        applianceInformations.removeAll()
        
        applianceInformations.insert(selectedAppliance.appliance.name, at: 0)
        
        // Version
        if let version = selectedAppliance.firmwareVersion {
            let applianceVersion = String(
                format: String(gsLocalized: "applianceselection_detail_additional_information_format"),
                String(gsLocalized: "applianceselection_detail_product_information_firmware_version_prefix"),
                version
            )
            
            applianceInformations.append(applianceVersion)
        }
        
        // Capacity
        if let selectedCapacity = selectedAppliance.selectedCapacity?.description {
            let applianceCapacity = String(
                format: String(gsLocalized: "applianceselection_detail_additional_information_format"),
                String(gsLocalized: "applianceselection_detail_product_information_capacity"),
                selectedCapacity
            )
            
            applianceInformations.append(applianceCapacity)
        }
        
        // User info
        customInfos.forEach { info in
            let title = String(
                format: String(gsLocalized: "applianceselection_detail_additional_information_format"),
                info.name,
                info.value
            )
            applianceInformations.append(title)
        }
    }
    
    static func fetchSelectedAppliances(
        _ state: ProductDetailsCore.State,
        _ environment: ProductDetailsCore.Environment
    ) -> Effect<Action, Never> {
        environment
            .selectedAppliancesService
            .getSelectedAppliance(productId: state.productId)
            .retrieveKitchenwares(
                kitchenwaresService: environment.kitchenwaresService
            )
            .flatMapLatest { (selectedAppliance, kitchenwares) in
                environment.productDetailUIDatasource
                    .getCustomInfos(selectedAppliance: selectedAppliance)
                    .map { (selectedAppliance, kitchenwares, $0) }
            }
            .catchToResult()
            .splitResultToActionEffect(
                action: { .updateCustomInfos($0, $1, $2) },
                failureAction: { .handleError($0.equatable) }
            )
    }
}
