//
//  ProductDetailUIDatasource.swift
//  GSMODApplianceSelectionView
//
//  Created by Eric Blachère on 10/12/2019.
//  Copyright © 2019 groupeseb. All rights reserved.
//

import Foundation

import GSMODApplianceSelectionKit

import RxSwift

/// Custom info to be displayed at the bottom of product detail screen
public struct ProductDetailCustomInfo: Hashable {
    /// Id
    public let id: String
    /// Name of the property
    public let name: String
    /// Value of the property
    public let value: String
    
    /// - Parameter name: Name of the property
    /// - Parameter value: Value of the property
    public init(_ name: String, _ value: String) {
        self.id = UUID().uuidString
        self.name = name
        self.value = value
    }
}

/// A protocol allowing client application to customize the informations displayed on the detail screen
public protocol ProductDetailUIDatasource {
    /// Gives the custom info to be displayed in the form "name : value" at the bottom of the screen
    /// - Parameter selectedAppliance: The selected appliance for which we want the infos
    func getCustomInfos(selectedAppliance: SelectedAppliance) -> Observable<[ProductDetailCustomInfo]>
    
    /// Returns true if delete button should be displayed or not.
    /// - Parameter selectedAppliance: The selected appliance to be possibly deleted
    /// - Parameter possibleAppliances: All the porssible appliances. (typically clients want to display the button if there is more than one appliance in the same domain)
    func shouldDisplayDeleteButton(selectedAppliance: SelectedAppliance, possibleAppliances: [Appliance]) -> Bool
}

public struct MockProductDetailUIDatasource: ProductDetailUIDatasource {
    
    let customInfos: [ProductDetailCustomInfo]
    
    public init(customInfos: [ProductDetailCustomInfo] = [ProductDetailCustomInfo("version", "6.6.6.mock")]) {
        self.customInfos = customInfos
    }
    
    public func getCustomInfos(selectedAppliance: SelectedAppliance) -> Observable<[ProductDetailCustomInfo]> {
        .just(customInfos)
    }
    
    public func shouldDisplayDeleteButton(selectedAppliance: SelectedAppliance, possibleAppliances: [Appliance]) -> Bool {
        possibleAppliances.count > 1
    }
}
