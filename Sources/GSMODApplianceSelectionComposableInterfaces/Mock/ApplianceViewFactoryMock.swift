//
//  ApplianceViewFactoryMock.swift
//
//
//  Created by Samir Tiouajni on 05/06/2024.
//

import SwiftUI



public struct ApplianceViewFactoryMock: ApplianceViewFactoryProtocol {
    
    public typealias Cores = ApplianceCoreMock
    
    public static func buildKitchenwareDetail(
        store: ApplianceKitchenwareDetailCoreMock<ApplianceBaseEnvironmentMock>.Store
    ) -> some View {
        Text("Dummy KitchenwareDetail")
    }
}
