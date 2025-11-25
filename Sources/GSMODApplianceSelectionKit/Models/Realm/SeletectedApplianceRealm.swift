//
//  SeletectedApplianceRealm.swift
//  GSMODApplianceSelectionKit
//
//  Created by Olivier Tavel on 06/08/2019.
//  Copyright © 2019 groupeseb. All rights reserved.
//

import Foundation




import RealmSwift

class SelectedApplianceRealm: Object {
    
    // Appliance
    @objc dynamic var applianceId: String = ""
    @objc dynamic var selectedCapacity: ApplianceCapacityRealm?
    let selectedKitchenwares = List<String>()

    // User Product
    @objc dynamic var productId: String = ""
    @objc dynamic var firmwareVersion: String?
    @objc dynamic var nickname: String?
    @objc dynamic var iotSerialId: String?
    @objc dynamic var source: String?
    
    @objc dynamic var creationDate: Date?
    @objc dynamic var modificationDate: Date?
    
    override static func primaryKey() -> String? {
        return "productId"
    }
    
    required convenience init(
        applianceId: String,
        productId: String?,
        firmwareVersion: String?,
        nickname: String?,
        capacity: Capacity?,
        kitchenwares: [String],
        iotSerialId: String?,
        source: String?,
        creationDate: Date?,
        modificationDate: Date?
    ) {
        self.init()
        self.applianceId = applianceId
        
        if let safeProductId = productId {
            self.productId = safeProductId
        } else {
            self.productId = UUID().uuidString
        }
        
        self.firmwareVersion = firmwareVersion
        self.nickname = nickname
        self.iotSerialId = iotSerialId
        self.source = source
        self.creationDate = creationDate
        self.modificationDate = modificationDate
        
        if let safeCapacity = capacity {
            self.selectedCapacity = ApplianceCapacityRealm(from: safeCapacity)
        }
        
        selectedKitchenwares.append(objectsIn: kitchenwares)
    }
    
    required convenience init(from selectedAppliance: SelectedAppliance) {
        self.init()
        
        self.applianceId = selectedAppliance.applianceId
        self.productId = selectedAppliance.productId
        self.firmwareVersion = selectedAppliance.firmwareVersion
        self.nickname = selectedAppliance.nickname
        self.iotSerialId = selectedAppliance.iotSerialId
        self.source = selectedAppliance.source
        self.creationDate = selectedAppliance.creationDate
        self.modificationDate = selectedAppliance.modificationDate
        
        if let capacity = selectedAppliance.selectedCapacity {
            self.selectedCapacity = ApplianceCapacityRealm(from: capacity)
        }
        
        selectedKitchenwares.append(objectsIn: selectedAppliance.selectedKitchenware)
    }
    
    func toSelectedAppliance(with appliance: Appliance) -> SelectedAppliance {
        var selectedAppliance = SelectedAppliance(
            appliance: appliance,
            creationDate: creationDate,
            modificationDate: modificationDate
        )

        selectedAppliance.selectedCapacity = selectedCapacity?.toCapacity()
        selectedAppliance.selectedKitchenware = Array(selectedKitchenwares)
        selectedAppliance.productId = productId
        selectedAppliance.firmwareVersion = firmwareVersion
        selectedAppliance.nickname = nickname
        selectedAppliance.iotSerialId = iotSerialId
        selectedAppliance.source = source

        return selectedAppliance
    }
    
    func update(from selectedAppliance: SelectedAppliance) {
        applianceId = selectedAppliance.applianceId
        nickname = selectedAppliance.nickname
        
        if let capacity = selectedAppliance.selectedCapacity {
            selectedCapacity = ApplianceCapacityRealm(from: capacity)
        }
        
        creationDate = selectedAppliance.creationDate
        modificationDate = selectedAppliance.modificationDate
        
        selectedKitchenwares.removeAll()
        selectedKitchenwares.append(objectsIn: selectedAppliance.selectedKitchenware)
    }
}

extension SelectedApplianceRealm: CascadeDeletable {
    var propertiesToCascadeDelete: [String] {
        return ["selectedCapacity", "selectedKitchenwares"]
    }
}
