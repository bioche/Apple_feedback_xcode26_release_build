//
//  ApplianceListFlowView.swift
//
//
//  Created by Samir Tiouajni on 02/06/2024.
//

import SwiftUI

import GSMODApplianceSelectionComposableInterfaces
import RxComposableArchitecture

struct ApplianceListFlowView<ViewFactory: ApplianceViewFactoryProtocol>: View {
    
    let store: ApplianceListCore<ViewFactory.Cores>.Store
    
    var body: some View {
        ApplianceListView<ViewFactory>(store: store)
//            .navigationBar()
//            .pushing(
//                destination: buildApplianceDeclarationView(store:),
//                parentStore: store,
//                state: { $0.applianceDeclaration },
//                action: { .applianceDeclaration($0) },
//                exitAction: .dismissApplianceDeclaration
//            )
    }
    
    @MainActor func buildApplianceDeclarationView(
        store: ApplianceDeclarationCore<ViewFactory.Cores>.Store
    ) -> some View {
        ApplianceDeclarationFlowView<ViewFactory>(store: store)
//            .navigationBar()
    }
}
