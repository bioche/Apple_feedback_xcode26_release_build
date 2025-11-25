//
//  ApplianceDeclarationFlowView.swift
//
//
//  Created by Samir Tiouajni on 02/06/2024.
//

import SwiftUI

import GSMODApplianceSelectionComposableInterfaces
import RxComposableArchitecture

public struct ApplianceDeclarationFlowView<ViewFactory: ApplianceViewFactoryProtocol>: View {
    
    let store: ApplianceDeclarationCore<ViewFactory.Cores>.Store
    
    public var body: some View {
        ApplianceDeclarationView<ViewFactory>(store: store)
//            .pushing(
//                destination: buildKitchenwareList(store:),
//                parentStore: store,
//                state: { $0.kitchenwareList },
//                action: { .kitchenwareList($0) },
//                exitAction: .dismissKitchenwareList
//            )
    }
    
    func buildKitchenwareList(store: KitchenwareListCore<ViewFactory.Cores>.Store) -> some View {
        KitchenwareListView<ViewFactory>(store: store)
            .toolbarRole(.editor)
    }
}
