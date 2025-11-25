//
//  File.swift
//  
//
//  Created by Thibault POUJAT on 25/05/2022.
//

import Foundation




extension KitchenwareListCore {
    
    typealias PageLoads = KitchenwareSelectionAnalytics.PageLoads
    typealias ButtonTouch = KitchenwareSelectionAnalytics.ButtonTouch
    typealias ListEvent = KitchenwareSelectionAnalytics.KitchenwareListEvent
    
    static var analyticsMiddleware: Self.Reducer { .init { _, action, env in
        switch action {
            
            
        default:
            break
        }
        return .none
    }}
}
