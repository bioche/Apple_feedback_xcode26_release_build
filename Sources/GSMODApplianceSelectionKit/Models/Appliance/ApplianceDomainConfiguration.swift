//
//  ApplianceDomainConfiguration.swift
//  
//
//  Created by Benjamin McMurrich on 17/03/2022.
//

import Foundation

public struct ApplianceDomainConfiguration: Hashable {
    public let name: String
    public let iconName: String?
    public let order: Int?
    
    public init(name: String, iconName: String? = nil, order: Int?) {
        self.name = name
        self.iconName = iconName
        self.order = order
    }
}
