//
//  ApplianceFirstSelectionCore+Functions.swift
//
//
//  Created by Samir Tiouajni on 03/06/2024.
//

import RxComposableArchitecture

import GSMODApplianceSelectionKit

extension ApplianceFirstSelectionCore {
    
    /// case 1: more than one domain -> CategorySelection(Domain)
    /// case 2: one domain
    ///   - many families -> CategorySelection(FamilySelection)
    ///   - one family
    ///        * many appliances -> ApplianceList
    ///        * one appliance -> ApplianceDeclaration
    static func setNavigation(
        _ env: ApplianceFirstSelectionCore.Environment,
        _ appliances: [Appliance],
        _ allowMultipleAppliancesPerDomain: Bool
    ) -> Effect<Action, Never> {
        let domainInfos = DomainInfo.generate(from: appliances)
        /// more than 1 domain
        if domainInfos.count > 1 || allowMultipleAppliancesPerDomain {
            return .just(.displayDomainSelection(domainInfos))
        } else {
            /// 1 domain
            guard let domainInfo = domainInfos.first else { return .none }
            /// more than 1 family
            if domainInfo.families.count > 1 {
                return .just(.displayApplianceFamilySelection(domainInfo))
            } else {
                /// 1 family
                /// more than 1 appliance
                if domainInfo.appliances.count > 1 {
                    return .just(.displayApplianceList(domainInfo.appliances))
                } else {
                    /// 1 appliance
                    let chosenAppliance = domainInfo.appliances[0]
                    return .just(.displayApplianceDeclaration(
                        chosenAppliance,
                        domainName: DomainInfo.domainName(
                            for: chosenAppliance.rawDomain,
                            env.configuration.applianceDomainConfigurations
                        ),
                        isAutoDetected: false
                    ))
                }
            }
        }
    }
    
    static func fetchAppliances(
        _ state: ApplianceFirstSelectionCore.State,
        _ environment: ApplianceFirstSelectionCore.Environment
    ) -> Effect<Action, Never> {
        environment.appliancesService
            .getAppliances()
            .retry(2)
            .catchToResult()
            .splitResultToActionEffect(
                action: { .fetchedAppliancesSuccess($0) },
                failureAction: { .handleError($0.equatable) }
            )
    }
}
