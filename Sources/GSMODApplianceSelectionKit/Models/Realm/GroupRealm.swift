//
//  GroupRealm.swift
//  GSMODApplianceSelectionKit
//
//  Created by Olivier Tavel on 24/06/2019.
//  Copyright © 2019 groupeseb. All rights reserved.
//

import Foundation

import Realm
import RealmSwift

class GroupRealm: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var name: String?
    @objc dynamic var resource_uri: String = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    required convenience init(from group: Group) {
        self.init()
        self.id = group.id
        self.name = group.name
        self.resource_uri = group.resource_uri
    }
    
    func toGroup() -> Group {
        return Group(id: id, name: name, resource_uri: resource_uri)
    }
}
