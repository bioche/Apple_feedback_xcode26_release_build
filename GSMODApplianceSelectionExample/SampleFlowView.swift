//
//  SampleFlowView.swift
//  PerfectMixExample
//
//  Created by Bioche on 29/12/2021.
//  Copyright © 2021 SEB. All rights reserved.
//

import SwiftUI

import GSMODApplianceSelectionComposableInterfaces
import RxComposableArchitecture

import GSMODApplianceSelectionView



struct SampleView: View {
    
    let store: SampleCore.Store
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            WithViewStore(store) { viewStore in
                VStack(spacing: 8) {
                    ForEach(viewStore.datas, id: \.self) { route in
                        Button(action: {
                            viewStore.send(.userTappedFirstSelection(route))
                        }) {
                            VStack(alignment: .leading) {
                                Text(route.rawValue)
                                    .font(.body)
                                    .foreground(\.contentMainColor)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Divider()
                                    .frame(height: 1)
                                    .foreground(\.contentLightColor)
                                
                            }
                        }
                        .frame(height: 40)
                    }
                }
                .alert(store.scope(state: \.errorAlert), dismiss: .dismissAlert)
                .padding(.horizontal, 16)
                .padding(.top, 40)
            }
        }
        .background(\.backgroundComplementaryColor)
    }
}

struct SampleFlowView: View {
    
    let store: SampleCore.Store
    
    var body: some View {
        SampleView(store: store)
            .presenting(
                destination: buildApplianceFirstSelection(store:),
                parentStore: store,
                state: { $0.firstSelection },
                action: { .firstSelection($0) },
                exitAction: .dismissFirstSelection
            )
            .presenting(
                destination: buildProductDetail(store:),
                parentStore: store,
                state: { $0.productDetail },
                action: { .productDetail($0) },
                exitAction: .dismissProductDetail
            )
            .pushing(
                destination: buildKitchenwareList(store:),
                parentStore: store,
                state: { $0.kitchenwareList },
                action: { .kitchenwareList($0) },
                exitAction: .dismissKitchenwareList
            )
    }
    
    @MainActor func buildApplianceFirstSelection(
        store: ApplianceFirstSelectionCore<ApplianceCoreMock>.Store
    ) -> some View {
        ApplianceFirstSelectionView<ApplianceViewFactoryMock>(
            store: store, wrapInNavigationStack: true
        )
        .navigationBar()
        .toolbarRole(.editor)
    }
    
    @MainActor func buildProductDetail(
        store: ProductDetailsCore<ApplianceCoreMock>.Store
    ) -> some View {
        ProductDetailsFlowView<ApplianceViewFactoryMock>(
            store: store,
            wrapInNavigationView: true,
            pairingPresenter: nil
        )
        .navigationBar()
    }
    
    @MainActor func buildKitchenwareList(
        store: KitchenwareListCore<ApplianceCoreMock>.Store
    ) -> some View {
        KitchenwareListFlowView<ApplianceViewFactoryMock>(store: store)
            .navigationBar()
    }
}
