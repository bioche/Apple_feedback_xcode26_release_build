//
//  SelectedAppliance.swift
//  GSMODApplianceSelectionKit
//
//  Created by Olivier Tavel on 25/06/2019.
//  Copyright © 2019 groupeseb. All rights reserved.
//

import Foundation



public typealias ProductId = String

@dynamicMemberLookup
public struct SelectedAppliance: Codable, Hashable {
    // Appliance
    public var appliance: Appliance
    public var selectedKitchenware: [KitchenwareId]
    public var selectedCapacity: Capacity?
    
    // User Product
    public var productId: ProductId
    public var firmwareVersion: String?
    public var nickname: String?
    public var iotSerialId: String?
    public var source: String?
    public var creationDate: Date?
    public var modificationDate: Date?
    
    public init(
        appliance: Appliance,
        productId: ProductId? = nil,
        firmwareVersion: String? = nil,
        nickname: String? = nil,
        capacity: Capacity? = nil,
        kitchenwares: [KitchenwareId] = [],
        iotSerialId: String? = nil,
        source: String? = nil,
        creationDate: Date?,
        modificationDate: Date?
    ) {
        self.appliance = appliance
        self.productId = productId ?? UUID().uuidString
        self.firmwareVersion = firmwareVersion
        self.nickname = nickname
        self.selectedCapacity = capacity
        self.selectedKitchenware = kitchenwares
        self.iotSerialId = iotSerialId
        self.source = source
        self.creationDate = creationDate
        self.modificationDate = modificationDate
    }
    
    func toUserProduct() -> UserProduct {
        .init(
            productId: productId,
            applianceId: appliance.applianceId,
            rawDomain: appliance.rawDomain,
            firmwareVersion: firmwareVersion,
            nickname: nickname,
            selectedCapacity: selectedCapacity,
            selectedKitchenwares: selectedKitchenware,
            iotSerialId: iotSerialId,
            source: source,
            // We set `nil` for both dates, DCP has its own management of creation and modification dates
            creationDate: nil,
            modificationDate: nil
        )
    }
    
    public subscript<T>(dynamicMember keyPath: KeyPath<Appliance, T>) -> T {
        appliance[keyPath: keyPath]
    }
}

extension SelectedAppliance: Comparable {
    public static func < (lhs: SelectedAppliance, rhs: SelectedAppliance) -> Bool {
        return lhs.applianceId < rhs.applianceId || lhs.rawDomain == rhs.rawDomain
    }
}

extension SelectedAppliance {
    public static func mock(id: String = UUID().uuidString) -> SelectedAppliance {
        UserProduct.mock(id: id).toSelectedAppliance(appliance: Appliance.stub())
    }
    
    public static func cookeoStub() -> SelectedAppliance {
        return UserProduct.cookeoStub().toSelectedAppliance(appliance: Appliance.cookeoStub())
    }

    public static func cookeoStubWithKitchenwares() -> SelectedAppliance {
        return UserProduct.cookeoStub().toSelectedAppliance(appliance: Appliance.cookeoStub())
    }

    public static func companionStub() -> SelectedAppliance {
        return UserProduct.companionStub().toSelectedAppliance(appliance: Appliance.companionStub())
    }
    
    public static func companionIOTStub() -> SelectedAppliance {
         return UserProduct.companionStub().toSelectedAppliance(appliance: Appliance.companionIOTStub())
    }
    
    public static func companionBLEStub() -> SelectedAppliance {
         return UserProduct.companionStub().toSelectedAppliance(appliance: Appliance.companionBLEStub())
    }
    
    public static func blenderStub() -> SelectedAppliance {
        return UserProduct.blenderStub().toSelectedAppliance(appliance: Appliance.blenderStub())
    }
    
    public static func cakeFactoryStub() -> SelectedAppliance {
        return UserProduct.cakeFactoryStub().toSelectedAppliance(appliance: Appliance.cakeFactoryStub())
    }
}
