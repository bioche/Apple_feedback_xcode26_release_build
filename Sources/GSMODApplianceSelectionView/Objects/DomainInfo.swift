//
//  DomainInfo.swift
//  GSMODApplianceSelectionView
//
//  Created by Hedi MESTIRI on 25/09/2020.
//  Copyright © 2020 groupeseb. All rights reserved.
//

import Foundation

import GSMODApplianceSelectionKit


public struct DomainInfo: Equatable {
    public let domain: RawDomain
    public let appliances: [Appliance]
    public let families: [ApplianceFamily]
    
    public static func generate(from appliances: [Appliance]) -> [DomainInfo] {
        let domains = Set(appliances.map({ $0.rawDomain }))
        
        // Create domain info array
        let domainsInfo: [DomainInfo] = domains.map { domain in
            let domainAppliances = appliances.filter { $0.rawDomain == domain }
            let domainFamilies = Array(Set(domainAppliances.compactMap { $0.applianceFamily }))
            
            return DomainInfo(
                domain: domain,
                appliances: domainAppliances,
                families: domainFamilies
            )
        }
        
        return domainsInfo
    }
    
    func toCategory(
        for applianceDomainConfigurations: [RawDomain: ApplianceDomainConfiguration]
    ) -> Category {
        .init(
            id: domain,
            name: DomainInfo.domainName(
                for: domain,
                applianceDomainConfigurations
            ),
            iconName: DomainInfo.domainIcon(
                for: domain,
                applianceDomainConfigurations
            ),
            order: DomainInfo.domainOrder(
                for: domain,
                applianceDomainConfigurations
            )
        )
    }
}

extension DomainInfo {
    static func domainName(
        for domain: RawDomain,
        _ applianceDomainConfigurations: [RawDomain: ApplianceDomainConfiguration]
    ) -> String {
        if let name = applianceDomainConfigurations[domain]?.name {
            return name
        } else {
            return domain
        }
    }
    
    static func domainIcon(
        for domain: RawDomain,
        _ applianceDomainConfigurations: [RawDomain: ApplianceDomainConfiguration]
    ) -> String? {
        if let icon = applianceDomainConfigurations[domain]?.iconName {
            return icon
        } else {
            return nil
        }
    }
    
    static func domainOrder(
        for domain: RawDomain,
        _ applianceDomainConfigurations: [RawDomain: ApplianceDomainConfiguration]
    ) -> Int? {
        return applianceDomainConfigurations[domain]?.order
    }
}
