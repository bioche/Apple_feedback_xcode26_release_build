//
//  Classification.swift
//  GSMODApplianceSelectionKit
//
//  Created by Olivier Tavel on 24/06/2019.
//  Copyright © 2019 groupeseb. All rights reserved.
//

import Foundation

/// The type (= nature) of the BLE Classification
enum ClassificationBLEType: String {
    case krell = "AC_PAIRING_BLE_KRELL"
    case seb = "AC_PAIRING_BLE_SEB"
}
/// The type (= nature) of the Multi Pairing Classification
enum ClassificationMultiPairingType: String {
    case authorized = "AC_MULTIPAIRING_TRUE"
    case unauthorized = "AC_MULTIPAIRING_FALSE"
}
/// The type (= nature) of the Marketing Classification
enum ClassificationMarketingType: String {
    case description = "MARKETING_DESCRIPTION"
}

/// The classification of an appliance
public struct Classification: Codable {
    public var id: String
    public var name: String?
    public var type: String?
    public var typeId: String?
    public var resourceUri: String?
    
    public init(id: String, name: String?, type: String?, typeId: String?, resourceUri: String?) {
        self.id = id
        self.name = name
        self.type = type
        self.typeId = typeId
        self.resourceUri = resourceUri
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try values.decode(String.self, forKey: .id)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        type = try values.decodeIfPresent(String.self, forKey: .type)
        typeId = try values.decodeIfPresent(String.self, forKey: .typeId)
        resourceUri = try values.decodeIfPresent(String.self, forKey: .resourceUri)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(type, forKey: .type)
        try container.encode(typeId, forKey: .typeId)
        try container.encode(resourceUri, forKey: .resourceUri)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case type
        case typeId
        case resourceUri = "resource_uri"
    }
}
