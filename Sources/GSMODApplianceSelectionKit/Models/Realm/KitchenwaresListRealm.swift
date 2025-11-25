//
//  KitchenwaresListRealm.swift
//  GSMODApplianceSelectionKit
//
//  Created by Olivier Tavel on 12/08/2019.
//  Copyright © 2019 groupeseb. All rights reserved.
//

import Foundation



import Realm
import RealmSwift

class KitchenwaresListRealm: Object {
    /// List of kitchenwares
    let kitchenwaresRealm = List<KitchenwareRealm>()
    
    // MARK: Cache added properties
    @objc dynamic var cacheIdentifierRealm = ""
    @objc dynamic var cacheDateRealm = Date()
    @objc dynamic var cachePolicyIdentifierRealm = ""
    
    required convenience init(from kitchenwaresList: KitchenwaresList) {
        self.init()
        kitchenwaresRealm.append(objectsIn: kitchenwaresList.kitchenwares.map({ KitchenwareRealm(from: $0) }))
    }
    
    override static func primaryKey() -> String? {
        return "cacheIdentifierRealm"
    }
    
    func toKitchenwaresList() -> KitchenwaresList {
        KitchenwaresList(kitchenwares: kitchenwaresRealm.map { $0.toKitchenware() }, cacheId: cacheIdentifierRealm)
    }
}

extension KitchenwaresListRealm: CascadeDeletable {
    var propertiesToCascadeDelete: [String] {
        return ["kitchenwaresRealm"]
    }
}

extension KitchenwaresListRealm: CachedRealmObject {
    func toObject() -> CachedRealm {
        toKitchenwaresList()
    }
    
    var cacheIdentifier: String {
        get { cacheIdentifierRealm }
        set { cacheIdentifierRealm = newValue }
    }
    
    var cacheDate: Date {
        get { cacheDateRealm }
        set { cacheDateRealm = newValue }
    }
    
    var cachePolicyIdentifier: String {
        get { cachePolicyIdentifierRealm }
        set { cachePolicyIdentifierRealm = newValue }
    }
}
