//
//  String+gsLocalized.swift
//  GSMODApplianceSelection
//
//  Created by Eric BLACHERE on 28/10/2024.
//

extension String {
    init(gsLocalized key: String.LocalizationValue) {
        self.init(localized: key, bundle: .applianceSelectionView)
    }
}
