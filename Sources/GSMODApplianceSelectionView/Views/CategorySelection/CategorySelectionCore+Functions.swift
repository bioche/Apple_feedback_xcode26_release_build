//
//  CategorySelectionCore+Functions.swift
//
//
//  Created by Samir Tiouajni on 02/06/2024.
//

import Foundation

import RxComposableArchitecture

import RxSwift

import GSMODApplianceSelectionKit

public struct SAVContent: Equatable {
    public let isPremium: Bool
    public let externalLink: URL
}

public struct Category: Equatable, Hashable {
    public let id: String
    public let name: String
    public let iconName: String?
    public let order: Int?
}

extension CategorySelectionCore {
    
    static func familiesNavigation(
        _ env: CategorySelectionCore.Environment,
        _ domainInfo: DomainInfo,
        _ categoryId: String
    ) -> Effect<Action, Never> {
        
        let filteredAppliances = domainInfo.appliances.filter { $0.applianceFamily?.id == categoryId }
        
        switch filteredAppliances.count {
        case 1:
            let chosenAppliance = filteredAppliances[0]
            return .just(.displayApplianceDeclaration(
                chosenAppliance,
                domainName: DomainInfo.domainName(
                    for: domainInfo.domain,
                    env.configuration.applianceDomainConfigurations
                )
            ))
        default:
            return .just(.displayApplianceList(filteredAppliances))
        }
    }
    
    static func categoriesNavigation(
        _ env: CategorySelectionCore.Environment,
        _ domainInfo: DomainInfo
    ) -> Effect<Action, Never> {
        
        if domainInfo.families.isNotEmpty && domainInfo.families.count > 1 {
            return .just(.displayApplianceFamilySelection(domainInfo))
        }
        
        switch domainInfo.appliances.count {
        case 1:
            let chosenAppliance = domainInfo.appliances[0]
            return .just(.displayApplianceDeclaration(
                chosenAppliance,
                domainName: DomainInfo.domainName(
                    for: domainInfo.domain,
                    env.configuration.applianceDomainConfigurations
                )
            ))
        default:
            return .just(.displayApplianceList(domainInfo.appliances))
        }
    }
    
    static func fetchSelectedProducts(
        state: State,
        env: Environment
    ) -> Effect<Action, Never> {
        env.selectedApplianceService
            .getSelectedAppliances()
            .flatMapLatest {
                Observable.from($0).retrieveKitchenwares(
                    kitchenwaresService: env.kitchenwaresService
                )
                .map { (selectedAppliance, kitchenwares) -> Product in
                    // Retrieve only selected kitchenware not in pack
                    let availableKitchenwares = kitchenwares.filter { $0.isSelectable }.count
                    let selectedKitchenwares = kitchenwares.filter({ $0.isSelectable && selectedAppliance.selectedKitchenware.contains($0.key) }).count
                    
                    return Product(
                        productId: selectedAppliance.productId,
                        availableKitchenwares: availableKitchenwares,
                        selectedKitchenwares: selectedKitchenwares,
                        selectedAppliance: selectedAppliance
                    )
                }
                .toArray()
            }
            .map({ products in
                return products.sorted(by: { $0.selectedAppliance.appliance.name < $1.selectedAppliance.appliance.name })
            })
            .catchToResult()
            .splitResultToActionEffect(
                action: { .updateProducts($0) },
                failureAction: { .handleError($0.equatable) }
            )
    }
}
