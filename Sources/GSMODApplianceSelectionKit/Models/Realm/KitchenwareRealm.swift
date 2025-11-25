//
//  KitchenwareRealm.swift
//  GSMODApplianceSelectionKit
//
//  Created by Olivier Tavel on 25/06/2019.
//  Copyright © 2019 groupeseb. All rights reserved.
//

import Foundation




import RealmSwift

class KitchenwareRealm: Object {
    
    @objc dynamic var key: String = ""
    @objc dynamic var isDefault: Bool = false
    @objc dynamic var isSelectable: Bool = false
    @objc dynamic var isConnectable: Bool = false
    @objc dynamic var nature: String?
    @objc dynamic var translatedName: String = ""
    let priority = RealmProperty<Int?>()
    let medias = List<MediaResponseApplianceRealm>()
    let availabilities = List<KitchenwareAvailabilityRealm>()
    let localizedUrls = List<KitchenwareLocalizedUrlRealm>()
    @objc dynamic var creationDate: Date?
    @objc dynamic var isD2CVisible: Bool = false

    required convenience init(from kitchenware: Kitchenware) {
        self.init()
        self.key = kitchenware.key
        self.isDefault = kitchenware.isDefault
        self.isSelectable = kitchenware.isSelectable
        self.isConnectable = kitchenware.isConnectable
        self.nature = kitchenware.nature
        self.translatedName = kitchenware.translatedName
        self.priority.value = kitchenware.priority
        self.creationDate = kitchenware.creationDate
        
        if let medias = kitchenware.medias {
            self.medias.append(objectsIn: medias.map({ MediaResponseApplianceRealm(from: $0) }))
        }
        self.availabilities.append(objectsIn: kitchenware.availabilities.map { KitchenwareAvailabilityRealm(from: $0) })

        if let localizedUrls = kitchenware.localizedUrls {
            self.localizedUrls.append(objectsIn: localizedUrls.map { KitchenwareLocalizedUrlRealm(from: $0) })
        }
        
        self.isD2CVisible = kitchenware.isD2CVisible
    }
    
    func toKitchenware() -> Kitchenware {
        let medias: [MediaResponse] = self.medias.map({ $0.toMediaResponse() })
        let availabilities: [KitchenwareAvailability] = self.availabilities.map({ $0.kitchenwareAvailability })
        let localizedUrls: [KitchenwareLocalizedUrl] = self.localizedUrls.map({ $0.toKitchenwareLocalizedUrl() })

        return Kitchenware(
            key: key,
            medias: medias,
            isDefault: isDefault,
            isSelectable: isSelectable,
            isConnectable: isConnectable,
            availabilities: availabilities,
            translatedName: translatedName,
            priority: priority.value,
            nature: nature,
            localizedUrls: localizedUrls,
            creationDate: creationDate,
            isD2CVisible: isD2CVisible
        )
    }
}

extension KitchenwareRealm: CascadeDeletable {
    var propertiesToCascadeDelete: [String] {
        return ["medias", "availabilities"]
    }
}
