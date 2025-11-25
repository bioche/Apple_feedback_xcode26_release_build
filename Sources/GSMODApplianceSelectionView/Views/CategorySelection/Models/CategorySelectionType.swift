//
//  CategorySelectionType.swift
//
//
//  Created by Samir Tiouajni on 02/06/2024.
//

import GSMODApplianceSelectionKit

public enum CategorySelectionType: Equatable {
    case domain([DomainInfo], [RawDomain: ApplianceDomainConfiguration])
    case family(DomainInfo, [RawDomain: ApplianceDomainConfiguration])
    
    var isDomain: Bool {
        switch self {
        case .domain:
            true
        case .family:
            false
        }
    }
    
    var domainsInfos: [DomainInfo] {
        switch self {
        case .domain(let array, _):
            return array
        case .family(let domainInfo, _):
            return [domainInfo]
        }
    }
    
    var categories: [Category] {
        switch self {
        case .domain(let domainInfos, let dictionary):
            return domainInfos.map { $0.toCategory(for: dictionary) }
        case .family(let domainInfo, _):
            return domainInfo.families.map {
                Category(id: $0.id, name: $0.name, iconName: nil, order: nil)
            }
        }
    }
}
