//
//  ApplianceViewFactoryProtocol.swift
//
//
//  Created by Samir Tiouajni on 04/06/2024.
//

import SwiftUI



public protocol ApplianceViewFactoryProtocol {
    associatedtype Cores: ApplianceCoreInterfaces
    
    associatedtype KitchenwareDetailView: View
    
    static func buildKitchenwareDetail(
        store: Cores.KitchenwareDetailCore.Store
    ) -> KitchenwareDetailView
}
