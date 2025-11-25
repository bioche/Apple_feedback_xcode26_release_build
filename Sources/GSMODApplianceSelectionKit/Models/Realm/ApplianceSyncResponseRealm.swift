//
//  ApplianceSyncResponseRealm.swift
//  GSMODApplianceSelectionKit
//
//  Created by Olivier Tavel on 07/08/2019.
//  Copyright © 2019 groupeseb. All rights reserved.
//

import Foundation




import RealmSwift

class ApplianceSyncResponseRealm: Object {
    @objc dynamic var cacheIdentifierRealm = ""
    @objc dynamic var cacheDateRealm = Date()
    @objc dynamic var cachePolicyIdentifierRealm = ""
    
    override static func primaryKey() -> String? {
        return "cacheIdentifierRealm"
    }
    
    let appliances = List<ApplianceRealm>()
    
    required convenience init(from applianceSyncResponse: ApplianceSyncResponse) {
        self.init()
        
        self.cacheIdentifierRealm = applianceSyncResponse.cacheId
        self.appliances.append(objectsIn: applianceSyncResponse.appliances.map { ApplianceRealm(from: $0) })
    }
    
    func toApplianceSyncResponse() -> ApplianceSyncResponse {
        let appliances: [Appliance] = self.appliances.map { $0.toAppliance() }
        return ApplianceSyncResponse(appliances: appliances, cacheId: cacheIdentifierRealm)
    }
}

extension ApplianceSyncResponseRealm: CachedRealmObject {
    func toObject() -> CachedRealm {
        toApplianceSyncResponse()
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
