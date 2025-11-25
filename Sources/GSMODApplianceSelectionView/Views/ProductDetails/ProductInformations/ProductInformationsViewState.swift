//
//  ProductInformationsViewState.swift
//
//
//  Created by Samir Tiouajni on 01/06/2024.
//

import RxComposableArchitecture
import GSMODApplianceSelectionKit

struct ProductInformationsViewState: Equatable {
    let productId: ProductId
    let applianceId: ApplianceId
    let shouldDisplayInformation: Bool
    let kitchenwareAvailable: Bool
    let kitchenwareTitle: String
    let capacityDescription: String?
    let applianceInformations: [String]
}

extension ProductDetailsCore.State {
    var view: ProductInformationsViewState {
        
        var kitchenwareTitle: String {
            switch selectedKitchenwaresCount {
            case 0:
                return String(gsLocalized: "applianceselection_detail_add_accessory_title")
            case 1:
                return String(gsLocalized: "applianceselection_add_an_accessory_number_singular")
            default:
                return String(
                    format: String(gsLocalized: "applianceselection_add_an_accessory_number_plural"),
                    selectedKitchenwaresCount
                )
            }
        }
        
        return .init(
            productId: productId, 
            applianceId: selectedAppliance?.applianceId ?? "",
            shouldDisplayInformation: shouldDisplayInformation,
            kitchenwareAvailable: kitchenwareAvailable,
            kitchenwareTitle: kitchenwareTitle,
            capacityDescription: selectedCapacity,
            applianceInformations: applianceInformations
        )
    }
}
