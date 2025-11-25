//
//  ApplianceCoreMock.swift
//
//
//  Created by Samir Tiouajni on 05/06/2024.
//

import Foundation

public struct ApplianceCoreMock: ApplianceCoreInterfaces {
    public typealias BaseEnvironment = ApplianceBaseEnvironmentMock
    public typealias KitchenwareDetailCore = ApplianceKitchenwareDetailCoreMock<ApplianceBaseEnvironmentMock>
}
