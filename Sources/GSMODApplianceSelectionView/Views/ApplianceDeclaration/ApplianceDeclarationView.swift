//
//  ApplianceDeclarationView.swift
//
//
//  Created by Samir Tiouajni on 29/03/2022.
//

import SwiftUI

import GSMODApplianceSelectionComposableInterfaces
import RxComposableArchitecture




private typealias Ids = AccessibilityIds
private typealias Localized = ApplianceSelectionLocalized.ApplianceDeclaration

struct ApplianceDeclarationView<ViewFactory: ApplianceViewFactoryProtocol>: View {
    
    let store: ApplianceDeclarationCore<ViewFactory.Cores>.Store
    
    var body: some View {
     EmptyView()
    }
}

extension ApplianceDeclarationCore.State {
    var defaultErrorAlert: AlertState<ApplianceDeclarationCore.Action> {
        .init(
            title: Localized.Alert.title,
            message: Localized.Alert.message,
            dismissButton: .cancel(send: .dismissAlert)
        )
    }
}
