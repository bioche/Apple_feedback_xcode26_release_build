//
//  CategoriesSectionView.swift
//
//
//  Created by Samir Tiouajni on 02/06/2024.
//

import SwiftUI

import RxComposableArchitecture



private typealias Ids = AccessibilityIds.CategorySelection
private typealias Localized = ApplianceSelectionLocalized.CategorySelection

struct CategoriesSectionView: View {
    
    let store: Store<CategoriesSectionViewState, CategoriesSectionViewAction>
    
    var body: some View {
     EmptyView()
    }
}
