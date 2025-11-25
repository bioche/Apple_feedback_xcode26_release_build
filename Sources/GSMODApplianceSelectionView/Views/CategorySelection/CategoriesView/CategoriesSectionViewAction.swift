//
//  CategoriesSectionViewAction.swift
//
//
//  Created by Samir Tiouajni on 03/06/2024.
//

import Foundation

enum CategoriesSectionViewAction: Equatable {
    case userTappedCategory(Category)
    case userTappedSAVDetail(URL)
}

extension CategorySelectionCore.Action {
    static func fromView(_ viewAction: CategoriesSectionViewAction) -> Self {
        switch viewAction {
        case .userTappedCategory(let category):
            return .userTappedCategory(category)
        case .userTappedSAVDetail(let url):
            return .userTappedSAVDetail(url)
        }
    }
}
