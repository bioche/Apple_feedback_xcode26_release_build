//
//  ApplianceSelectionLocalized.swift
//  
//
//  Created by Samir Tiouajni on 22/05/2024.
//

import Foundation

struct ApplianceSelectionLocalized {
    
    static var navigationBarTitle: String {
        String(gsLocalized: "applianceselection_categoryselection_navigationbar_title")
    }
    
    struct ApplianceDeclaration {
        
        static var capacityLabel: String { 
            String(gsLocalized: "applianceselection_categoryselection_product_capacity")
        }
        
        static var continueButton: String {
            String(gsLocalized: "applianceselection_applianceedition_continue_button")
        }
        
        static var addAccessoryLabel: String {
            String(gsLocalized: "applianceselection_detail_add_accessory_title")
        }
        
        static var singleAccessory: String {
            String(gsLocalized: "applianceselection_add_an_accessory_number_singular")
        }
        
        static var manyAccessories: String {
            String(gsLocalized: "applianceselection_add_an_accessory_number_plural")
        }
        
        struct Alert {
            static var title: String {
                String(gsLocalized: "applianceselection_generic_error_title_ios")
            }
            
            static var message: String {
                String(gsLocalized: "applianceselection_generic_error_message_ios")
            }
        }
    }
    
    struct CategorySelection {
        
        static var familySelectionTitle: String {
            String(gsLocalized: "applianceselection_categoryselection_title_family")
        }
        
        static var domainSelectionTitle: String {
            String(gsLocalized: "applianceselection_categoryselection_title_domain")
        }
        
        static var selectedProductSectionTitle: String {
            String(gsLocalized: "applianceselection_categoryselection_selectedproduct_section_title")
        }
        
        static var instructionAddDomain: String {
            String(gsLocalized: "applianceselection_categoryselection_instruction_add_domain")
        }
        
        static var instructionDomain: String {
            String(gsLocalized: "applianceselection_categoryselection_instruction_domain")
        }
        
        static var instructionFamily: String {
            String(gsLocalized: "applianceselection_categoryselection_instruction_family")
        }
        
        static var footerDescription: String {
            String(gsLocalized: "applianceselection_categoryselection_footer")
        }
        
        static var notFoundButtonTitle: String {
            String(gsLocalized: "applianceselection_categoryselection_instruction_domain_not_found")
        }
        
        static var validationButton: String {
            String(gsLocalized: "applianceselection_categoryselection_validation_button")
        }
        
        static var errorTitle: String {
            String(gsLocalized: "applianceselection_generic_error_title_ios")
        }
        
        static var errorMessage: String {
            String(gsLocalized: "applianceselection_generic_error_message_ios")
        }
        
        static var productCapacity: String {
            String(gsLocalized: "applianceselection_categoryselection_product_capacity")
        }
        
        struct NotFound {
            
            static var title: String {
                String(gsLocalized: "applianceselection_categoryselection_instruction_domain_not_found")
            }
            
            static var description: String {
                String(gsLocalized: "applianceselection_categoryselection_appliance_not_found_description")
            }
            
            static var message: String {
                String(gsLocalized: "applianceselection_categoryselection_appliance_not_found_message")
            }
            
            static var savButton: String {
                String(gsLocalized: "applianceselection_categoryselection_appliance_not_found_sav_button")
            }
        }
    }
    
    struct ProductDetails {
        
        static var nicknameTextFieldPlaceholder: String {
            String(gsLocalized: "applianceselection_applianceedition_edit_instruction")
        }
        
        static var capacityLabel: String {
            String(gsLocalized: "applianceselection_categoryselection_product_capacity")
        }
        
        static var manualLabel: String {
            String(gsLocalized: "applianceselection_detail_manual_button")
        }
        
        static var deleteButtonTitle: String {
            String(gsLocalized: "applianceselection_detail_delete_product")
        }
        
        struct CardProductPairing {
            static var title: String {
                String(gsLocalized: "applianceselection_detail_product_card_association_title")
            }
            
            static var subtitle: String {
                String(gsLocalized: "applianceselection_detail_product_card_association_subtitle")
            }
            
            static var button: String {
                String(gsLocalized: "applianceselection_detail_product_card_association_button")
            }
        }
        
        struct Alert {
            static var title: String {
                String(gsLocalized: "applianceselection_detail_delete_product_title_ios")
            }
            
            static var message: String {
                String(gsLocalized: "applianceselection_detail_delete_product_warning")
            }
            
            static var confirmButton: String {
                String(gsLocalized: "applianceselection_detail_delete_product_confirm_button_ios")
            }
            
            static var cancelButton: String {
                String(gsLocalized: "applianceselection_detail_delete_product_cancel_button_ios")
            }
        }
    }
    
    struct CapacitySelection {
        
        static var pickerCancelButton: String {
            String(gsLocalized: "applianceselection_product_capacity_selection_cancel_button")
        }
        
        static var pickerValidateButton: String {
            String(gsLocalized: "applianceselection_product_capacity_selection_validate_button_ios")
        }
        
        static var pickerInformationCapacity: String {
            String(gsLocalized: "applianceselection_detail_product_information_capacity")
        }
    }
    
    struct KitchenwareList {
        static func title(disclosureType: DisclosureType, applianceName: String) -> String {
            switch disclosureType {
            case .info, .none:
                return String(gsLocalized: "applianceselection_accessoryselection_title")
            case .arrow:
                return String(
                    format: String(gsLocalized: "applianceselection_accessory_list_title"),
                    applianceName
                )
            }
        }
        
        static func declareButton(for kitchenwaresCount: Int) -> String {
            String(
                format: kitchenwaresCount > 1
                    ? String(gsLocalized: "applianceselection_declare_an_accessory_number_plural")
                    : String(gsLocalized: "applianceselection_declare_an_accessory_number_singular"),
                kitchenwaresCount
            )
        }
        
        static var inPackKitchenwaresSectionTitle: String {
            String(gsLocalized: "applianceselection_accessoryselection_basic_view_title")
        }
        
        static var complementaryKitchenwaresSectionTitle: String {
            String(gsLocalized: "applianceselection_accessoryselection_complementary_view_title")
        }
    }
    
    struct ApplianceFirstSelection {
        
        static var errorMessage: String {
            String(gsLocalized: "applianceselection_detail_generic_error_message")
        }
        
        static var retryButtonTitle: String {
            String(gsLocalized: "applianceselection_categoryselection_retry")
        }

        static var selectProductTitle: String {
            String(
                gsLocalized: "applianceselection_applianceselection_title_ios"
            )
        }

        static var nearbyProductsTitle: String {
            String(
                gsLocalized: "applianceselection_applianceselection_nearby_products_title_ios"
            )
        }

        static var allProductsTitle: String {
            String(
                gsLocalized: "applianceselection_applianceselection_all_products_title_ios"
            )
        }

        static var searchingNearbyProductsLabel: String {
            String(
                gsLocalized: "applianceselection_applianceselection_nearby_products_searching_ios"
            )
        }
    }
}
