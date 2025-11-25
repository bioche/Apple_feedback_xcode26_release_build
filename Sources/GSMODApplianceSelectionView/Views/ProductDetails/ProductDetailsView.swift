//
//  ProductDetailsView.swift
//  
//
//  Created by Samir Tiouajni on 25/03/2022.
//

import SwiftUI

import GSMODApplianceSelectionComposableInterfaces
import RxComposableArchitecture

import RxRelay


private typealias Localized = ApplianceSelectionLocalized.ProductDetails

struct ProductDetailsView<ViewFactory: ApplianceViewFactoryProtocol>: View {
    
    @State private var keyboardDisplayed = false
    
    let store: ProductDetailsCore<ViewFactory.Cores>.Store
    let isCloseButtonHidden: Bool
    
    var body: some View {
     EmptyView()
    }
}

extension ProductDetailsCore.State {
    var deletionConfirmationAlert: AlertState<ProductDetailsCore.Action> {
        .init(
            title: Localized.Alert.title,
           message: Localized.Alert.message,
            primaryButton: .destructive(
                Localized.Alert.confirmButton, send: .validateDeletion
            ),
            secondaryButton: .cancel(
                Localized.Alert.cancelButton, send: .dismissAlert
            )
        )
    }
}
