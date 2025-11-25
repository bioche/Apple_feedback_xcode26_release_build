//
//  ApplianceListCore+Analytics.swift
//
//
//  Created by Samir Tiouajni on 01/06/2024.
//

import RxComposableArchitecture



extension ApplianceListCore {
    private typealias ButtonTouch = Analytics.ButtonTouch
    private typealias PageLoads = Analytics.PageLoads
    
    static var analyticsMiddleware: Self.Reducer { .init { _, action, env in
        switch action {
        case .userTappedApplianceCell(let appliance):
            break
            
        default:
            break
        }
        return .none
    }}
}
