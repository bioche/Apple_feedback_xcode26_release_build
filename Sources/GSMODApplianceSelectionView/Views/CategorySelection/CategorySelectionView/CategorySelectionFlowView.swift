//
//  CategorySelectionFlowView.swift
//
//
//  Created by Samir Tiouajni on 02/06/2024.
//

import SwiftUI

import GSMODApplianceSelectionComposableInterfaces
import RxComposableArchitecture

public struct CategorySelectionFlowView<ViewFactory: ApplianceViewFactoryProtocol>: View {
    
    let store: CategorySelectionCore<ViewFactory.Cores>.Store
    
    public var body: some View {
        CategorySelectionView<ViewFactory>(store: store)
//            .navigationBar()
//            .pushing(
//                destination: applianceListView(store:),
//                parentStore: store,
//                state: { $0.applianceList },
//                action: { .applianceList($0) },
//                exitAction: .dismissApplianceList
//            )
//            .pushing(
//                destination: productDetailsView(store:),
//                parentStore: store,
//                state: { $0.productDetails },
//                action: { .productDetails($0) },
//                exitAction: .dismissProductDetails
//            )
//            .pushing(
//                destination: CategorySelectionFlowView<ViewFactory>.init(store:),
//                parentStore: store,
//                state: { $0.familySelection },
//                action: { .familySelection($0) },
//                exitAction: .dismissFamilySelection
//            )
//            .pushing(
//                destination: applianceDeclarationView(store:),
//                parentStore: store,
//                state: { $0.applianceDeclaration },
//                action: { .applianceDeclaration($0) },
//                exitAction: .dismissApplianceDeclaration
//            )
//            .pushing(
//                destinationFromState: {
//                    CategoryNotFoundView(
//                        url: $0.externalLink,
//                        isPremium: $0.isPremium, 
//                        pageload: { store.send(.savViewDidAppear) }, 
//                        pageDisappeared: { store.send(.leaveSAVDetail) }, 
//                        savButtonTapped: { store.send(.userTappedSAVButton) }
//                    )
//                },
//                parentStore: store,
//                state: { $0.savContent },
//                exitAction: .leaveSAVDetail
//            )
    }
    
    @MainActor func applianceListView(
        store: ApplianceListCore<ViewFactory.Cores>.Store
    ) -> some View {
        ApplianceListFlowView<ViewFactory>(store: store)
//            .navigationBar()
    }
    
    @MainActor func productDetailsView(
        store: ProductDetailsCore<ViewFactory.Cores>.Store
    ) -> some View {
        ProductDetailsFlowView<ViewFactory>(
            store: store,
            wrapInNavigationView: false, 
            pairingPresenter: nil
        )
//        .navigationBar()
    }
    
    @MainActor func applianceDeclarationView(
        store: ApplianceDeclarationCore<ViewFactory.Cores>.Store
    ) -> some View {
        ApplianceDeclarationFlowView<ViewFactory>(store: store)
//            .navigationBar()
    }
    
    @MainActor func familySelectionView(
        store: CategorySelectionCore<ViewFactory.Cores>.Store
    ) -> some View {
        CategorySelectionFlowView<ViewFactory>(store: store)
//            .navigationBar()
    }
}
