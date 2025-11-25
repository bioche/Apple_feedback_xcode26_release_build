//
//  ProductDetailsCore+Analytics.swift
//
//
//  Created by Samir Tiouajni on 01/06/2024.
//




extension ProductDetailsCore {
    
    private typealias ButtonTouch = Analytics.ButtonTouch
    private typealias PageLoads = Analytics.PageLoads
    
    public static var analyticsMiddleware: Self.Reducer { .init { _, action, env in
        switch action {
            
        default:
            break
        }
        return .none
    }}
}
