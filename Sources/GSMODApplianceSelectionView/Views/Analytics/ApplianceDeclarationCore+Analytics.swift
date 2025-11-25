//
//  ApplianceDeclarationCore+Analytics.swift
//
//
//  Created by Samir Tiouajni on 01/06/2024.
//

import RxComposableArchitecture



extension ApplianceDeclarationCore {
    private typealias ButtonTouch = Analytics.ButtonTouch
    private typealias PageLoads = Analytics.PageLoads
    
    static var analyticsMiddleware: Self.Reducer { .init { state, action, env in
        switch action {

            
        default:
            break
        }
        return .none
    }}
}
