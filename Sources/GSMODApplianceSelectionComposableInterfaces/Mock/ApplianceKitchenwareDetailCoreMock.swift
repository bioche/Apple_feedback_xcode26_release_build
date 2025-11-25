//
//  ApplianceKitchenwareDetailCoreMock.swift
//
//
//  Created by Samir Tiouajni on 05/06/2024.
//

import Foundation



import GSMODApplianceSelectionKit

public struct ApplianceKitchenwareDetailCoreMock<BaseEnvironment: ApplianceBaseEnvironmentProtocol>: ApplianceKitchenwareDetailCoreItf {
    
    public struct State: ApplianceKitchenwareDetailStateItf {
        public static func initial(
            kitchenwareDetailConfiguration: KitchenwareDetailConfiguration
        ) -> ApplianceKitchenwareDetailCoreMock.State {
            .init()
        }
    }
    
    public struct Action: Equatable {}
    
    public struct Environment: ApplianceKitchenwareDetailEnvironmentItf {        

        public static func live(
            base: BaseEnvironment
        ) -> ApplianceKitchenwareDetailCoreMock.Environment {
            .init()
        }
        
        public static func mock(
            servicesFactory: ApplianceServicesFactory,
            base: BaseEnvironment
        ) -> ApplianceKitchenwareDetailCoreMock.Environment {
            .init()
        }
    }
    
    public static var featureReducer: Reducer { .empty }
}
