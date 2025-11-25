//
//  ProductDetailsFlowView.swift
//
//
//  Created by Samir Tiouajni on 02/06/2024.
//


import SwiftUI

import Combine

import GSMODApplianceSelectionComposableInterfaces

import RxComposableArchitecture

import GSMODApplianceSelectionKit

public struct ProductDetailsFlowView<ViewFactory: ApplianceViewFactoryProtocol>: View {
    
    let store: ProductDetailsCore<ViewFactory.Cores>.Store
    let wrapInNavigationView: Bool
    /// closure to send for pairing view when tapped on associate button
    let pairingPresenter: AppliancePairingPresenter?
    
    public init(
        store: ProductDetailsCore<ViewFactory.Cores>.Store,
        wrapInNavigationView: Bool,
        pairingPresenter: AppliancePairingPresenter?
    ) {
        self.store = store
        self.wrapInNavigationView = wrapInNavigationView
        self.pairingPresenter = pairingPresenter
    }
    
    public var body: some View {
        WithViewStore(store.scope(state: { $0.displayProductPairing })) { viewStore in
            VStack {
                if wrapInNavigationView {
                    NavigationView {
                        productDetailsContent(store: store)
//                            .enableNavigation()
//                            .navigationBar()
                    }
                    .navigationViewStyle(.stack)
                } else {
                    productDetailsContent(store: store)
                }
            }
            .onChange(of: viewStore.state) { displayPairing in
                if displayPairing {
                    guard let selectedAppliance = store.state.selectedAppliance else { return }
                    pairingPresenter?.showPairingWifi(
                        for: selectedAppliance,
                        onFinished: {
                            store.send(.dismissAppliancePairing)
                        }
                    )
                }
            }
        }
    }
    
    @MainActor @ViewBuilder
    func productDetailsContent(
        store: ProductDetailsCore<ViewFactory.Cores>.Store
    ) -> some View {
        ProductDetailsView<ViewFactory>(
            store: store,
            isCloseButtonHidden: !wrapInNavigationView
        )
//        .pushing(
//            destination: buildKitchenwareList(store:),
//            parentStore: store,
//            state: { $0.kitchenwareList },
//            action: { .kitchenwareList($0) },
//            exitAction: .dismissKitchenwareList
//        )
    }
    
    func buildKitchenwareList(
        store: KitchenwareListCore<ViewFactory.Cores>.Store
    ) -> some View {
        KitchenwareListFlowView<ViewFactory>(store: store)
    }
}
