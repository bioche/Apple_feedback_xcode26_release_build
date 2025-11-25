//
//  AccessibilityIds.swift
//  GSMODApplianceSelectionView
//
//  Created by Benjamin McMurrich on 23/02/2022.
//

import Foundation

struct AccessibilityIds {
    
    static let applianceSelectionButton = "applianceselection_applianceedition_selection_button"
    static let removeApplianceButton = "applianceselection_applianceedition_remove_button"
    static let applianceDeclareKitchenwares = "applianceselection_applianceedition_declare_kitchenwares_button"
    static let applianceNickname = "applianceselection_applianceedition_applianceNickname"
    
    static let applianceValidationButton = "applianceselection_applianceselection_validate_button"
    static let applianceCarousel = "applianceselection_applianceselection_carousel"
    
    struct CategorySelection {
        
        static let productTitle = "ProductSelectionTitle"
        static let addProductSubtitle = "ProductSelectionAddProductSubtitle"
        static let addProductList = "ProductSelectionAddProductList"
        static let addProductListRow = "ProductSelectionAddProductRow"
        static let addProductListRowIcon = "ProductSelectionAddProductRowIcon"
        static let addProductListRowTitle = "ProductSelectionAddProductRowTitle"
        static let addProductListRowArrow = "ProductSelectionAddProductRowArrow"
        
        static let selectedProductsSubtitle = "ProductSelectionMyProductsSubtitle"
        static let selectedProductsList = "ProductSelectionMyProductsList"
        
        static let modelTitle = "ModelSelectionTitle"
        static let addModelSubtitle = "ModelSelectionSelectModelSubtitle"
        static let addModelList = "ModelSelectionSelectModelList"
        static let addModelListRow = "ModelSelectionSelectModelRow"
        static let addModelListRowTitle = "ModelSelectionSelectModelRowTitle"
        static let addModelListRowArrow = "ModelSelectionSelectModelRowArrow"
        
        static let userHint = "ProductSelectionUserHint"
        static let productNotFound = "CommunProductNotFound"
        static let productNotFoundIcon = "CommunProductNotFoundIcon"
        static let productNotFoundLabel = "CommunProductNotFoundLabel"
        static let domainValidationButton = "ProductSelectionValidateBtn"
        
        struct NotFoundAccessibility {
            static let title = "ProductNotFoundTitle"
            static let description = "ProductNotFoundDescription"
            static let savTitle = "ProductNotFoundSAVTile"
            static let message = "ProductNotFoundSAVTileTitle"
            static let savButton = "ProductNotFoundSAVTileCTA"
            static let savImage = "ProductNotFoundSAVTileImage"
        }
    }
}
