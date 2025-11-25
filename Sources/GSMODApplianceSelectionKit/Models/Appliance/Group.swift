//
//  Group.swift
//  GSMODApplianceSelectionKit
//
//  Created by Olivier Tavel on 24/06/2019.
//  Copyright © 2019 groupeseb. All rights reserved.
//

import Foundation



public struct Group: Codable {
    public let id: String
    public let name: String?
    public let resource_uri: String
}

extension Group: Stub {
    public static func stub() -> Group {
        return Group(id: "a group", name: "a stubbed group", resource_uri: "stubbedGroup")
    }
}

extension Group {
    func toRealmObject() -> GroupRealm {
        return GroupRealm(from: self)
    }
}
