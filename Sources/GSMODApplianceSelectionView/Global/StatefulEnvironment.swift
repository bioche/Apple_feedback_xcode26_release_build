//
//  StatefulEnvironment.swift
//  
//
//  Created by Eric BLACHERE on 18/08/2022.
//

import Foundation

/// Wraps an environment that needs to be kept in memory over time
/// ⚠️ In theory we should avoid having such environment & use this class as little as possible
/// An exemple of stateful service that still needs this is FilterManager which still keeps
/// filters in its internal state
/// Call `reset` method when starting Core that uses this kind of environment.
public class StatefulEnvironment<Wrapped> {
    
    let factory: () -> Wrapped
    private var stored: Wrapped?
    
    public init(factory: @escaping () -> Wrapped) {
        self.factory = factory
    }
    
    public static func stateful(
        _ factory: @autoclosure @escaping () -> Wrapped
    ) -> StatefulEnvironment<Wrapped> {
        StatefulEnvironment<Wrapped>(factory: factory)
    }
    
    public var value: Wrapped {
        let env = stored ?? factory()
        stored = env
        return env
    }
    
    public func reset() {
        stored = factory()
    }
}
