//
//  CategoriesSectionViewState.swift
//
//
//  Created by Samir Tiouajni on 03/06/2024.
//

import Foundation

struct CategoriesSectionViewState: Equatable {
    
    let categories: [Category]
    let categorySelectionType: CategorySelectionType
    let savExternalLink: SAVExternalLinkStatus
    let showSelectedAppliances: Bool
    let applianceEditableLaterLabelHidden: Bool
}

extension CategorySelectionCore.State {
    var view: CategoriesSectionViewState {
        .init(
            categories: availableCategories,
            categorySelectionType: categorySelectionType,
            savExternalLink: savExternalLink,
            showSelectedAppliances: showSelectedAppliances,
            applianceEditableLaterLabelHidden: applianceEditableLaterLabelHidden
        )
    }
}
