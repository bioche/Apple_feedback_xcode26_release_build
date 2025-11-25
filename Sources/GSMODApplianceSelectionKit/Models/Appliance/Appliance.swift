//
//  Appliance.swift
//  GSMODApplianceSelectionKit
//
//  Created by Olivier Tavel on 24/06/2019.
//  Copyright © 2019 groupeseb. All rights reserved.
//

import UIKit


public typealias ApplianceId = String
public typealias RawDomain = String

public enum ApplianceConnectableType {
    case ble
    case iot
    case none
}

public struct Appliance: Codable, CustomStringConvertible {
    
    public var applianceId: ApplianceId
    public var name: String
    public var lang: String
    public var market: String
    public var capacities: [Capacity]
    public var media: String?
    public var rawDomain: RawDomain
    public var applianceFamily: ApplianceFamily?
    public var resource_uri: String?
    public var group: Group?
    public var classifications: [Classification]
    public var order: Int?
    public var thingType: String?
    
    // this should be replaced with classifications for good in DCP but it's still not the case
    // today in October 2021 ...
    var legacy_connectable: Bool
    
    public init(id: ApplianceId,
                name: String,
                lang: String,
                market: String,
                capacities: [Capacity],
                media: String?,
                rawDomain: RawDomain,
                applianceFamily: ApplianceFamily?,
                resource_uri: String?,
                group: Group?,
                connectable: Bool = false,
                classifications: [Classification],
                order: Int?,
                thingType: String?) {
        self.applianceId = id
        self.name = name
        self.lang = lang
        self.market = market
        self.capacities = capacities
        self.media = media
        self.rawDomain = rawDomain
        self.applianceFamily = applianceFamily
        self.resource_uri = resource_uri
        self.group = group
        self.classifications = classifications
        self.order = order
        self.thingType = thingType
        self.legacy_connectable = connectable
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        if let rawDomain = try? values.decode(RawDomain.self, forKey: .domain) { // from our encoding
            self.rawDomain = rawDomain
        } else { // from DCP
            let rawDomains = try values.decode([RawDomain].self, forKey: .domain)
            guard let rawDomain = rawDomains.first else {
                throw DecodingError.dataCorrupted(.init(
                    codingPath: [CodingKeys.domain],
                    debugDescription: "Domain is an empty array ..."
                ))
            }
            self.rawDomain = rawDomain
        }
        
        applianceId = try values.decode(ApplianceId.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        lang = try values.decode(String.self, forKey: .lang)
        market = try values.decode(String.self, forKey: .market)
        capacities = try values.decodeIfPresent([Capacity].self, forKey: .capacities) ?? []
        applianceFamily = try values.decodeIfPresent(ApplianceFamily.self, forKey: .applianceFamily)
        resource_uri = try values.decodeIfPresent(String.self, forKey: .resource_uri)
        group = try values.decodeIfPresent(Group.self, forKey: .group)
        
        if let media = try? values.decodeIfPresent(String.self, forKey: .media) { // from our encoding
            self.media = media
        } else { // from DCP
            self.media = try values.decodeIfPresent([ApplianceMedia].self, forKey: .media)?.first?.thumbs
        }
        
        classifications = try values.decodeIfPresent([Classification].self, forKey: .classifications) ?? []
        order = try values.decodeIfPresent(Int.self, forKey: .order)
        thingType = try values.decodeIfPresent(String.self, forKey: .thingType)
        legacy_connectable = try values.decodeIfPresent(Bool.self, forKey: .connectable) ?? false
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(applianceId, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(lang, forKey: .lang)
        try container.encode(market, forKey: .market)
        try container.encode(capacities, forKey: .capacities)
        try container.encode(applianceFamily, forKey: .applianceFamily)
        try container.encode(resource_uri, forKey: .resource_uri)
        try container.encode(group, forKey: .group)
        try container.encode(rawDomain, forKey: .domain)
        try container.encode(media, forKey: .media)
        try container.encode(classifications, forKey: .classifications)
        try container.encode(order, forKey: .order)
        try container.encode(thingType, forKey: .thingType)
        try container.encode(legacy_connectable, forKey: .connectable)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case lang
        case market
        case capacities
        case media = "medias"
        case domain = "domains"
        case applianceFamily
        case resource_uri
        case group
        case classifications
        case kitchenwares
        case order
        case thingType
        case connectable
    }
    
    public var description: String {
        return ""
    }
    
    public var groupId: String {
        group?.id ?? "" // group should always be there but still officially optional
    }
    
}

// extension for connectivity
public extension Appliance {
    
    var connectableType: ApplianceConnectableType {
        if classifications.contains(where: { $0.id == ClassificationBLEType.krell.rawValue })
            || classifications.contains(where: { $0.id == ClassificationBLEType.seb.rawValue }) {
            return .ble
        } else if let strongThingType = thingType,
                  !strongThingType.isEmpty {
            return .iot
        } else {
            return legacy_connectable == true ? .ble : .none
        }
    }
    
    var multiPairingAuthorized: Bool {
        return classifications.contains(where: { $0.id == ClassificationMultiPairingType.authorized.rawValue })
    }
    
    var marketingDescription: String? {
        return classifications
            .filter { $0.typeId == ClassificationMarketingType.description.rawValue }
            .compactMap { $0.name }.first
    }
    
    var isConnectable: Bool { connectableType != .none }
    
    var urlMedia: URL? {
        if let ressourceUrl = self.media?.replacingOccurrences(of: "{size}/", with: "original/") {
            return URL(string: ressourceUrl)
        }
        
        return nil
    }
}

extension Appliance {
    public static func stub() -> Appliance {
        return Appliance(id: "StubAppliance", name: "stubAppliance", lang: "fr", market: "GS_FR", capacities: [], media: nil, rawDomain: "PRO_COO", applianceFamily: nil, resource_uri: "stub uri", group: .stub(), classifications: [], order: 50, thingType: "thingTypeStub")
    }

    public static func stub(name: String) -> Appliance {
        return Appliance(id: "StubAppliance", name: name, lang: "fr", market: "GS_FR", capacities: [], media: nil, rawDomain: "PRO_COO", applianceFamily: nil, resource_uri: "stub uri", group: .stub(), classifications: [], order: 50, thingType: "thingTypeStub")
    }

    public static func companionStub() -> Appliance {
        return Appliance(id: "APPLIANCE_167", name: "Companion", lang: "fr", market: "GS_FR", capacities: [], media: "https://sebplatform.api.groupe-seb.com/statics/{size}/df34b9d2-9d0b-45a3-9a5b-f750e47bfdec.png", rawDomain: "PRO_COM", applianceFamily: nil, resource_uri: nil, group: Group(id: "APPLIANCE_GROUP_16", name: "Companion", resource_uri: "APPLIANCE_GROUP_16"), classifications: [], order: nil, thingType: "companionThingTypeStub")
    }
    
    public static func companionIOTStub() -> Appliance {
        return Appliance(id: "APPLIANCE_167", name: "Companion", lang: "fr", market: "GS_FR", capacities: [], media: "https://sebplatform.api.groupe-seb.com/statics/{size}/df34b9d2-9d0b-45a3-9a5b-f750e47bfdec.png", rawDomain: "PRO_COM", applianceFamily: nil, resource_uri: nil, group: Group(id: "APPLIANCE_GROUP_16", name: "Companion", resource_uri: "APPLIANCE_GROUP_16"), classifications: [], order: nil, thingType: "companionThingTypeStub")
    }
    
    public static func companionBLEStub() -> Appliance {
        return Appliance(id: "APPLIANCE_167", name: "Companion", lang: "fr", market: "GS_FR", capacities: [], media: "https://sebplatform.api.groupe-seb.com/statics/{size}/df34b9d2-9d0b-45a3-9a5b-f750e47bfdec.png", rawDomain: "PRO_COM", applianceFamily: nil, resource_uri: nil, group: Group(id: "APPLIANCE_GROUP_16", name: "Companion", resource_uri: "APPLIANCE_GROUP_16"), classifications: [Classification(id: ClassificationBLEType.seb.rawValue, name: nil, type: nil, typeId: ClassificationMarketingType.description.rawValue, resourceUri: nil)], order: nil, thingType: "companionThingTypeStub")
    }
    
    public static func cookeoStub() -> Appliance {
        return Appliance(id: "APPLIANCE_1085", name: "Cookeo + gourmet", lang: "fr", market: "GS_FR", capacities: [], media: "https://sebplatform.api.groupe-seb.com/statics/{size}/0adf2988-4fcb-43d7-b9e6-396aa96d31e8.png", rawDomain: "PRO_COO", applianceFamily: nil, resource_uri: nil, group: Group(id: "APPLIANCE_GROUP_15", name: "Cookeo", resource_uri: "APPLIANCE_GROUP_15"), classifications: [], order: nil, thingType: "cookeoThingTypeStub")
    }
    
    public static func blenderStub() -> Appliance {
        return Appliance(id: "APPLIANCE_2022", name: "Blender", lang: "fr", market: "GS_FR", capacities: [], media: "https://sebplatform.api.groupe-seb.com/statics/{size}/0adf2988-4fcb-43d7-b9e6-396aa96d31e8.png", rawDomain: "PRO_BLE", applianceFamily: nil, resource_uri: nil, group: Group(id: "APPLIANCE_GROUP_1051", name: "Perfectmix Cook", resource_uri: "APPLIANCE_GROUP_1051"), classifications: [], order: nil, thingType: "blenderThingTypeStub")
    }
    
    public static func cakeFactoryStub() -> Appliance {
        return Appliance(id: "APPLIANCE_1070", name: "Cake Factory", lang: "fr", market: "GS_FR", capacities: [], media: "https://sebplatform.api.groupe-seb.com/statics/{size}/APPLIANCE_1070", rawDomain: "PRO_CAK", applianceFamily: nil, resource_uri: nil, group: Group(id: "APPLIANCE_GROUP_1013", name: "Cake Factory", resource_uri: "APPLIANCE_GROUP_1013"), classifications: [], order: nil, thingType: "cakeFactoryThingTypeStub")
    }
    
    public static func smartTastyStub() -> Appliance {
        return Appliance(
            id: "APPLIANCE_110",
            name: "Clipso + Precision",
            lang: "fr",
            market: "GS_FR",
            capacities: [
                .init(quantity: 4.5, unit: "UNIT_32"),
                .init(quantity: 6, unit: "UNIT_32"),
                .init(quantity: 8, unit: "UNIT_32"),
                .init(quantity: 10, unit: "UNIT_32")
            ],
            media: "https://sebplatform.api.groupe-seb.com/statics/{size}/327532fb-a1fc-416c-b83a-561ae63b5f17.png",
            rawDomain: "PRO_AUT",
            applianceFamily: .init(
                id: "APPLIANCE_FAMILY_3",
                name: "Clipso",
                resource_uri: "APPLIANCE_FAMILY_3"
            ),
            resource_uri: nil,
            group: Group(
                id: "APPLIANCE_GROUP_5",
                name: "ActiCook",
                resource_uri: "APPLIANCE_GROUP_5"
            ),
            classifications: [],
            order: 14,
            thingType: ""
        )
    }
    
    public static func smartTastyStub1() -> Appliance {
        return Appliance(
            id: "APPLIANCE_111",
            name: "Clipso +",
            lang: "fr",
            market: "GS_FR",
            capacities: [
                .init(quantity: 4.5, unit: "UNIT_32"),
                .init(quantity: 6, unit: "UNIT_32"),
                .init(quantity: 8, unit: "UNIT_32"),
                .init(quantity: 10, unit: "UNIT_32")
            ],
            media: "https://sebplatform.api.groupe-seb.com/statics/{size}/327532fb-a1fc-416c-b83a-561ae63b5f17.png",
            rawDomain: "PRO_AUT",
            applianceFamily: .init(
                id: "APPLIANCE_FAMILY_2",
                name: "Clipso",
                resource_uri: "APPLIANCE_FAMILY_2"
            ),
            resource_uri: nil,
            group: Group(
                id: "APPLIANCE_GROUP_5",
                name: "ActiCook",
                resource_uri: "APPLIANCE_GROUP_5"
            ),
            classifications: [],
            order: 14,
            thingType: ""
        )
    }
    
    public static func aspirobotStub() -> Appliance {
        return Appliance(id: "APPLIANCE_510007", name: "Aspirobot", lang: "fr", market: "GS_FR", capacities: [], media: "https://sebplatform.api.groupe-seb.com/statics/{size}/APPLIANCE_510007", rawDomain: "PRO_ROB", applianceFamily: nil, resource_uri: nil, group: Group(id: "APPLIANCE_GROUP_1013", name: "Cake Factory", resource_uri: "APPLIANCE_GROUP_1013"), classifications: [], order: nil, thingType: "aspirobotThingTypeStub")
    }
}

extension Appliance: Equatable {}
public func == (lhs: Appliance, rhs: Appliance) -> Bool {
    return lhs.applianceId == rhs.applianceId
}

extension Appliance: Comparable {
    public static func < (lhs: Appliance, rhs: Appliance) -> Bool {
        if let orderL = lhs.order, let orderR = rhs.order {
            return orderL < orderR
        } else if lhs.order == nil && rhs.order == nil {
            return lhs.name < rhs.name
        } else {
            return lhs.order != nil
        }
    }
}

extension Appliance: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(applianceId)
    }
}
