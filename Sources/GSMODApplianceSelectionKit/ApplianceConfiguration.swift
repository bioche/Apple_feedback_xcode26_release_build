//
//  ApplianceConfiguration.swift
//  GSMODApplianceSelectionView
//
//  Created by Olivier Tavel on 11/07/2019.
//  Copyright © 2019 groupeseb. All rights reserved.
//

import Foundation

import RxSwift

/// Global configuration of the module
public struct ApplianceConfiguration {
    /// The locale we want the appliances of
    public let locale: GSLocale
    /// Type of synchronize for devices
    public let syncType: SyncType
    /// Client application identifier
    public let appIdentifier: String
    /// Check if the theme is premium or not
    public let isPremium: Bool
    /// List of names and icons for specific domains
    public let applianceDomainConfigurations: [RawDomain: ApplianceDomainConfiguration]
    /// Brand name
    public var brandName: String
    
    public init(
        locale: GSLocale,
        syncType: SyncType,
        appIdentifier: String,
        isPremium: Bool,
        brandName: String,
        applianceDomainConfigurations: [RawDomain: ApplianceDomainConfiguration]
    ) {
        self.locale = locale
        self.syncType = syncType
        self.appIdentifier = appIdentifier
        self.isPremium = isPremium
        self.brandName = brandName
        self.applianceDomainConfigurations = applianceDomainConfigurations
    }
}
