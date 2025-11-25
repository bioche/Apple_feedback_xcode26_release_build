//
//  CategorySelectionView.swift
//
//
//  Created by Samir Tiouajni on 02/06/2024.
//

import SwiftUI

import GSMODApplianceSelectionComposableInterfaces
import RxComposableArchitecture



private typealias Ids = AccessibilityIds.CategorySelection
private typealias Localized = ApplianceSelectionLocalized.CategorySelection

struct CategorySelectionView<ViewFactory: ApplianceViewFactoryProtocol>: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    let store: CategorySelectionCore<ViewFactory.Cores>.Store
    
    var body: some View {
     EmptyView()
    }
}
