//
//  SelectedAppliancesListView.swift
//
//
//  Created by Samir Tiouajni on 02/06/2024.
//

import SwiftUI

import GSMODApplianceSelectionComposableInterfaces

import GSMODApplianceSelectionKit


private typealias Ids = AccessibilityIds.CategorySelection
private typealias Localized = ApplianceSelectionLocalized.CategorySelection

struct SelectedAppliancesListView<ViewFactory: ApplianceViewFactoryProtocol>: View {
    
    let selectedProducts: [CategorySelectionCore<ViewFactory.Cores>.Product]
    let onTapProduct: (CategorySelectionCore<ViewFactory.Cores>.Product) -> Void
    
    var body: some View {
     EmptyView()
    }
}
