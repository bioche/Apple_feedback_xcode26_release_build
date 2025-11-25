//
//  CapacitySelectionView.swift
//  GSMODApplianceSelectionView
//
//  Created by MESTIRI Hedi on 20/10/2020.
//  Copyright © 2020 groupeseb. All rights reserved.
//

import SwiftUI

import RxComposableArchitecture

import GSMODApplianceSelectionKit



private typealias Localized = ApplianceSelectionLocalized.CapacitySelection

public struct CapacitySelectionView: View {
    
    let store: CapacitySelectionCore.Store

    public var body: some View {
     EmptyView()
    }
}

extension Capacity: Identifiable {
    public var id: Int {
        hashValue
    }
}

struct CapacitySelectionView_Previews: PreviewProvider {
    static var previews: some View {
        CapacitySelectionView(
            store: .init(
                initialState: .initial(
                    configuration: .init(
                        capacities: [
                            Capacity(quantity: 2, unit: "L"),
                            Capacity(quantity: 4, unit: "L"),
                            Capacity(quantity: 6, unit: "L")],
                        defaultCapacity: Capacity(quantity: 2, unit: "L")
                    )
                ),
                reducer: CapacitySelectionCore.featureReducer,
                environment: .init()
            )
        )
    }
}
