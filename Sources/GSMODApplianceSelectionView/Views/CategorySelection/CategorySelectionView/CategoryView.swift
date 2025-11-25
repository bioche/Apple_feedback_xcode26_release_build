//
//  CategoryView.swift
//
//
//  Created by Samir Tiouajni on 02/06/2024.
//

import SwiftUI



private typealias Ids = AccessibilityIds.CategorySelection
private typealias Localized = ApplianceSelectionLocalized.CategorySelection

struct CategoryView: View {
    let category: Category
    let type: CategorySelectionType
    let onTap: () -> Void
    
    var body: some View {
     EmptyView()
    }
}
