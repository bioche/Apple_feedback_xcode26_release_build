//
//  ApplianceHeaderView.swift
//  GSMODApplianceSelectionView
//
//  Created by Hedi MESTIRI on 22/10/2020.
//  Copyright © 2020 groupeseb. All rights reserved.
//

import SwiftUI

import RxComposableArchitecture




private typealias Localized = ApplianceSelectionLocalized.ProductDetails

struct ApplianceHeaderView: View {
    
    let store: Store<ApplianceHeaderViewState, ApplianceHeaderViewAction>
    let geometryReader: GeometryProxy
    
    var body: some View {
     EmptyView()
    }
}
