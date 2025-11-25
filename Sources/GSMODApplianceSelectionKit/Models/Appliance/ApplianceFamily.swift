//
//  ApplianceFamily.swift
//  GSMODApplianceSelectionKit
//
//  Created by Olivier Tavel on 24/06/2019.
//  Copyright © 2019 groupeseb. All rights reserved.
//

import Foundation

public protocol Stub {
    static func stub() -> Self
}


public struct ApplianceFamily: Codable {
    public var id: String
    public var name: String
    public var resource_uri: String
}

extension ApplianceFamily: Stub {
    public static func stub() -> ApplianceFamily {
        return ApplianceFamily(id: "stub family", name: "stub family", resource_uri: "stub ressourceURi")
    }
}

extension ApplianceFamily: Equatable {}
public func == (lhs: ApplianceFamily, rhs: ApplianceFamily) -> Bool {
    return lhs.id == rhs.id
}

extension ApplianceFamily: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
