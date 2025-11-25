//
//  KitchenwareListFlowView.swift
//
//
//  Created by Samir Tiouajni on 06/06/2024.
//

import SwiftUI

import GSMODApplianceSelectionComposableInterfaces


public struct KitchenwareListFlowView<ViewFactory: ApplianceViewFactoryProtocol>: View {
    
    let store: KitchenwareListCore<ViewFactory.Cores>.Store
    
    public init(store: KitchenwareListCore<ViewFactory.Cores>.Store) {
        self.store = store
    }
    
    public var body: some View {
        KitchenwareListView<ViewFactory>(store: store)
//            .pushing(
//                destination: buildKitchenwareDetailFlowView(store:),
//                parentStore: store,
//                state: { $0.kitchenwareDetail },
//                action: { .kitchenwareDetail($0) },
//                exitAction: .dismissKitchenwareDetail
//            )
    }
    
    func buildKitchenwareDetailFlowView(
        store: ViewFactory.Cores.KitchenwareDetailCore.Store
    ) -> some View {
        ViewFactory.buildKitchenwareDetail(store: store)
    }
}
