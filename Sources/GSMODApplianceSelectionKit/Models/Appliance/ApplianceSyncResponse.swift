//
//  Appliancesyncresponse.swift
//  GSMODApplianceSelectionKit
//
//  Created by Olivier Tavel on 24/06/2019.
//  Copyright © 2019 groupeseb. All rights reserved.
//

import Foundation

import RealmSwift

struct RawApplianceSyncResponse: Decodable {
    let appliances: [Appliance]
    
    enum CodingKeys: String, CodingKey {
        case appliances = "objects"
    }
}

struct ApplianceSyncResponse {
    let appliances: [Appliance]
    let cacheId: String
}

extension ApplianceSyncResponse {
    init(appliances: [Appliance], locale: GSLocale, syncType: SyncType) {
        self.appliances = appliances
        self.cacheId = AppliancesQueryBundle.id(locale: locale, syncType: syncType)
    }
}

extension ApplianceSyncResponse: CachedRealm {
    func toRealmObject() -> CachedRealmObject {
        ApplianceSyncResponseRealm(from: self)
    }
}

/// Protocol to objects need to be cached in Realm
public protocol CachedRealm: CachedObject {
    func toRealmObject() -> CachedRealmObject
}

/// Protocol dedicated to Realm objects and add cache on them
public protocol CachedRealmObject: Object {
    var cacheIdentifier: String { get set }
    var cacheDate: Date { get set }
    var cachePolicyIdentifier: String { get set }
    
    /// Transform CachedRealmObject object to a CachedObject
    func toObject() -> CachedRealm
}
