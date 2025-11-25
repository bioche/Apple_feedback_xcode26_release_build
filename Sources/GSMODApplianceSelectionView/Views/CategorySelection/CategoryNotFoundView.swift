//
//  CategoryNotFoundView.swift
//
//
//  Created by Samir Tiouajni on 22/05/2024.
//

import SwiftUI



private typealias Ids = AccessibilityIds.CategorySelection.NotFoundAccessibility
private typealias Localized = ApplianceSelectionLocalized.CategorySelection.NotFound

struct CategoryNotFoundView: View {
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.openURL) var openURL
    
    let url: URL
    let isPremium: Bool
    let pageload: () -> Void
    let pageDisappeared: () -> Void
    let savButtonTapped: () -> Void
    
    var body: some View {
     EmptyView()
    }
}
