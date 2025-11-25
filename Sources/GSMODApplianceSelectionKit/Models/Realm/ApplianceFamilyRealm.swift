//
//  ApplianceFamilyRealm.swift
//  GSMODApplianceSelectionKit
//
//  Created by Olivier Tavel on 06/08/2019.
//  Copyright © 2019 groupeseb. All rights reserved.
//

import Foundation

import RealmSwift

class ApplianceFamilyRealm: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var resource_uri: String = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    required convenience init(from applianceFamily: ApplianceFamily) {
        self.init()
        self.id = applianceFamily.id
        self.name = applianceFamily.name
        self.resource_uri = applianceFamily.resource_uri
    }
    
    func toApplianceFamily() -> ApplianceFamily {
        return ApplianceFamily(id: id, name: name, resource_uri: resource_uri)
    }
}
