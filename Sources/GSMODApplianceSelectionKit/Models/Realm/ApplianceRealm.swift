//
//  ApplianceRealm.swift
//  GSMODApplianceSelectionKit
//
//  Created by Olivier Tavel on 24/06/2019.
//  Copyright © 2019 groupeseb. All rights reserved.
//

import Foundation




import Realm
import RealmSwift

class ApplianceRealm: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var lang: String = ""
    @objc dynamic var market: String = ""
    @objc dynamic var media: String = ""
    @objc dynamic var domain: String = ""
    @objc dynamic var applianceFamily: ApplianceFamilyRealm?
    @objc dynamic var resource_uri: String?
    @objc dynamic var group: GroupRealm?
    @objc dynamic var thingType: String = ""
    @objc dynamic var legacy_connectable: Bool = false

    let order = RealmProperty<Int?>()
    let capacities = List<ApplianceCapacityRealm>()
    let classifications = List<ClassificationRealm>()
 
    open override class func primaryKey() -> String? {
        return "id"
    }
    
    required convenience init(from appliance: Appliance) {
        self.init()
        
        self.id = appliance.applianceId
        self.name = appliance.name
        self.lang = appliance.lang
        self.market = appliance.market
        self.media = appliance.media ?? ""
        self.domain = appliance.rawDomain
        self.legacy_connectable = appliance.legacy_connectable
        self.resource_uri = appliance.resource_uri
        
        if let family = appliance.applianceFamily {
            self.applianceFamily = ApplianceFamilyRealm(from: family)
        }
        
        if let group = appliance.group {
            self.group = GroupRealm(from: group)
        }
        
        self.order.value = appliance.order
        self.thingType = appliance.thingType ?? ""
        
        self.classifications.append(objectsIn: appliance.classifications.map { ClassificationRealm(from: $0) })
        self.capacities.append(objectsIn: appliance.capacities.map { ApplianceCapacityRealm(from: $0) })
    }
    
    func toAppliance() -> Appliance {
        let applianceFamily = self.applianceFamily?.toApplianceFamily()
        let capacities: [Capacity] = self.capacities.map { $0.toCapacity() }
        let classifications: [Classification] = self.classifications.map { $0.toClassification() }
        
        return Appliance(
            id: id,
            name: name,
            lang: lang,
            market: market,
            capacities: capacities,
            media: media,
            rawDomain: domain,
            applianceFamily: applianceFamily,
            resource_uri: nil,
            group: group?.toGroup(),
            connectable: legacy_connectable,
            classifications: classifications,
            order: order.value,
            thingType: thingType
        )
    }
}

extension ApplianceRealm: CachedObject {
    var cacheId: String {
        return id
    }
}
