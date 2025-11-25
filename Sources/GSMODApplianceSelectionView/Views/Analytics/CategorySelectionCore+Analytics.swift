//
//  CategorySelectionCore+Analytics.swift
//
//
//  Created by Samir Tiouajni on 02/06/2024.
//





extension CategorySelectionCore {
    private typealias ButtonTouch = Analytics.ButtonTouch
    private typealias PageLoads = Analytics.PageLoads
    
    public static var analyticsMiddleware: Self.Reducer { .init { state, action, env in
        switch action {
            
        default:
            break
        }
        return .none
    }}
}

public struct TouchUpInsideEvent: GSEvent {
    public var isForSebana: Bool = true
    public var eventType: String = "BUTTON_TOUCHED_INSIDE"
    public var parameterValues: [String: JSONObject] = [:]
    public init(action: String) {
        parameterValues["action"] = action
    }
}
