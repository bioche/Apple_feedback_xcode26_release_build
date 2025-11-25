//
//  Kitchenware.swift
//  GSMODApplianceSelectionKit
//
//  Created by Olivier Tavel on 25/06/2019.
//  Copyright © 2019 groupeseb. All rights reserved.
//

import Foundation




import RealmSwift

public typealias KitchenwareId = String

public struct MediaResponse: Codable, Hashable {
    public let identifier: String?
    public let isCover: Bool?
    public let media: Media?
    public let captionTitle: String?
    public let captionText: String?
    
    public init(identifier: String? = nil, isCover: Bool? = nil, media: Media? = nil, captionTitle: String? = nil, captionText: String? = nil) {
        self.identifier = identifier
        self.isCover = isCover
        self.media = media
        self.captionTitle = captionTitle
        self.captionText = captionText
    }
}

public struct Media: Hashable {
    public let key: String?
    // Equivalent of 'key', DCP send us sometimes an 'id' instead of 'key'.
    public let id: String?
    public let type: String?
    public let original: String?
    public let thumbnail: String?
    // Equivalent of 'thumbnail', DCP send us sometimes a 'thumbs' instead of 'thumbnail'.
    public let thumbs: String?
    public let originalFilename: String?
    public let isDisabled: Bool?
    public let mediaMetadata: MediaMetadata?
    
    public init(
        key: String? = nil,
        id: String? = nil,
        type: String? = nil,
        original: String? = nil,
        thumbnail: String? = nil,
        thumbs: String? = nil,
        originalFilename: String? = nil,
        creationDate: Date? = nil,
        releaseDate: Date? = nil,
        isDisabled: Bool? = nil,
        mediaMetadata: MediaMetadata? = nil
    ) {
        self.key = key
        self.id = id
        self.type = type
        self.original = original
        self.thumbnail = thumbnail
        self.thumbs = thumbs
        self.originalFilename = originalFilename
        self.isDisabled = isDisabled
        self.mediaMetadata = mediaMetadata
    }
}

public struct MediaMetadata: Codable, Hashable {
    public let width: Int?
    public let height: Int?
    public let size: Int?
    public let length: Int?
    public let mimeType: String?
    
    public init(width: Int? = nil, height: Int? = nil, size: Int? = nil, length: Int? = nil, mimeType: String? = nil) {
        self.width = width
        self.height = height
        self.size = size
        self.length = length
        self.mimeType = mimeType
    }
}

extension Media: Codable {
    enum CodingKeys: String, CodingKey {
        case key, id, type, original, thumbnail, thumbs, originalFilename, creationDate, releaseDate,
             isDisabled, mediaMetadata
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.key = try container.decodeIfPresent(String.self, forKey: .key)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.type = try container.decodeIfPresent(String.self, forKey: .type)
        self.original = try container.decodeIfPresent(String.self, forKey: .original)
        self.thumbnail = try container.decodeIfPresent(String.self, forKey: .thumbnail)
        self.thumbs = try container.decodeIfPresent(String.self, forKey: .thumbs)
        self.originalFilename = try container.decodeIfPresent(String.self, forKey: .originalFilename)
        self.isDisabled = try container.decodeIfPresent(Bool.self, forKey: .isDisabled)
        self.mediaMetadata = try container.decodeIfPresent(MediaMetadata.self, forKey: .mediaMetadata)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(key, forKey: .key)
        try container.encode(type, forKey: .type)
        try container.encode(original, forKey: .original)
        try container.encode(thumbnail, forKey: .thumbnail)
        try container.encode(originalFilename, forKey: .originalFilename)
        try container.encode(isDisabled, forKey: .isDisabled)
        try container.encode(mediaMetadata, forKey: .mediaMetadata)
    }
}


public struct Kitchenware: Codable {

    public var key: KitchenwareId
    public var medias: [MediaResponse]?
    public var isDefault: Bool
    public var isSelectable: Bool
    public var isConnectable: Bool
    public var availabilities: [KitchenwareAvailability]
    public var translatedName: String
    public var priority: Int?
    public var nature: String?
    public var localizedUrls: [KitchenwareLocalizedUrl]?
    private var _creationDate: String?
    private var _isD2CVisible: Bool?
    
    /// To convert String to Date to delete custom Decoder
    public var creationDate: Date? {
        if let _creationDate {
            return Date(dcpFormattedString: _creationDate)
        }
        return nil
    }
    
    /// Unwrapp isD2CVisible to a value of type 'Bool'
    public var isD2CVisible: Bool {
        if let _isD2CVisible {
            return _isD2CVisible
        } else {
            return false
        }
    }

    /// "in pack" means that the product was sold with this kitchenware,
    /// the user doesn't have to buy it separately
    public var isInPack: Bool {
        availabilities.contains(where: { availability in
            return availability.compatibilities.contains(where: { $0.type == .inPack })
        })
    }
    
    public init(
        key: KitchenwareId,
        medias: [MediaResponse]? = nil,
        isDefault: Bool,
        isSelectable: Bool,
        isConnectable: Bool,
        availabilities: [KitchenwareAvailability],
        translatedName: String,
        priority: Int? = nil,
        nature: String? = nil,
        localizedUrls: [KitchenwareLocalizedUrl]? = nil,
        creationDate: Date?,
        isD2CVisible: Bool
    ) {
        self.key = key
        self.medias = medias
        self.isDefault = isDefault
        self.isSelectable = isSelectable
        self.isConnectable = isConnectable
        self.availabilities = availabilities
        self.translatedName = translatedName
        self.priority = priority
        self.nature = nature
        self.localizedUrls = localizedUrls
        self._creationDate = creationDate?.toString()
        self._isD2CVisible = isD2CVisible
    }
    
    enum CodingKeys: String, CodingKey {
        case key
        case medias
        case isDefault
        case isSelectable
        case isConnectable
        case availabilities
        case translatedName
        case priority
        case nature
        case localizedUrls
        case _creationDate = "creationDate"
        case _isD2CVisible = "isD2CVisible"
    }
}

public extension Kitchenware {
    /// Return the media url for a specific thumbnail size
    ///
    /// - Returns: URL?
    func mediaUrl() -> URL? {
        let ressourceUrl = self.medias?.first?.media?.original?.replacingOccurrences(of: "{size}", with: "\(126 * 2)x\(126 * 2)")
        return URL(string: ressourceUrl ?? "")
    }
}

extension Kitchenware: Stub {

    public static func stub() -> Kitchenware {
        let mediaResponse = MediaResponse(identifier: nil, isCover: nil, media: nil, captionTitle: nil, captionText: nil)
        let compatibility = KitchenwareCompatibility(applianceGroup: "APPLIANCE_GROUP_1010", type: .inPack)
        let kitchenwareAvailability = KitchenwareAvailability(market: "GS_FR", compatibilities: [compatibility])
        
        return Kitchenware(
            key: "KITCHENWARE_6",
            medias: [mediaResponse],
            isDefault: false,
            isSelectable: false,
            isConnectable: false,
            availabilities: [kitchenwareAvailability],
            translatedName: "Batteur",
            priority: 1,
            nature: "KITCHEN_SCALE",
            localizedUrls: nil,
            creationDate: nil, 
            isD2CVisible: true
        )
    }
    
    public static func cookeoStub() -> Kitchenware {
        let mediaResponse = MediaResponse(identifier: nil, isCover: nil, media: nil, captionTitle: nil, captionText: nil)
        let compatibility = KitchenwareCompatibility(applianceGroup: "APPLIANCE_GROUP_1015", type: .outOfPack)
        let kitchenwareAvailability = KitchenwareAvailability(market: "GS_FR", compatibilities: [compatibility])
        
        return Kitchenware(
            key: "KITCHENWARE_10011",
            medias: [mediaResponse],
            isDefault: false,
            isSelectable: true,
            isConnectable: false,
            availabilities: [kitchenwareAvailability],
            translatedName: "Grameez",
            priority: 1,
            nature: "KITCHEN_SCALE",
            localizedUrls: nil,
            creationDate: nil,
            isD2CVisible: true
        )
    }
    
    public static func companionStub() -> Kitchenware {
        let mediaResponse = MediaResponse(identifier: nil, isCover: nil, media: nil, captionTitle: nil, captionText: nil)
        let compatibility = KitchenwareCompatibility(applianceGroup: "APPLIANCE_GROUP_1016", type: .outOfPack)
        let kitchenwareAvailability = KitchenwareAvailability(market: "GS_FR", compatibilities: [compatibility])
        
        return Kitchenware(
            key: "KITCHENWARE_10000",
            medias: [mediaResponse],
            isDefault: false,
            isSelectable: true,
            isConnectable: false,
            availabilities: [kitchenwareAvailability],
            translatedName: "Découpe légumes",
            priority: 1,
            nature: nil,
            localizedUrls: nil,
            creationDate: nil,
            isD2CVisible: true
        )
    }
    
    public static func cakeFactoryStub() -> Kitchenware {
        let mediaResponse = MediaResponse(identifier: nil, isCover: nil, media: nil, captionTitle: nil, captionText: nil)
        let compatibility = KitchenwareCompatibility(applianceGroup: "APPLIANCE_GROUP_1013", type: .inPack)
        let kitchenwareAvailability = KitchenwareAvailability(market: "GS_FR", compatibilities: [compatibility])
        
        return Kitchenware(
            key: "KITCHENWARE_10014",
            medias: [mediaResponse],
            isDefault: false,
            isSelectable: true,
            isConnectable: false,
            availabilities: [kitchenwareAvailability],
            translatedName: "Moule à 6 muffins PROflex",
            priority: 1,
            nature: nil,
            localizedUrls: nil,
            creationDate: nil,
            isD2CVisible: true
        )
    }
    
    public static func aspirobotStub() -> Kitchenware {
        let mediaResponse = MediaResponse(identifier: nil, isCover: nil, media: nil, captionTitle: nil, captionText: nil)
        let compatibility = KitchenwareCompatibility(applianceGroup: "APPLIANCE_GROUP_1002", type: .inPack)
        let kitchenwareAvailability = KitchenwareAvailability(market: "GS_FR", compatibilities: [compatibility])
        
        return Kitchenware(
            key: "KITCHENWARE_510002",
            medias: [mediaResponse],
            isDefault: false,
            isSelectable: true,
            isConnectable: false,
            availabilities: [kitchenwareAvailability],
            translatedName: "BROSSETTE",
            priority: 1,
            nature: "ROBOT_BRUSH",
            localizedUrls: [
                .init(
                    redirectionUrl: "https://www.moulinex.fr/boutique-accessoires/Preparation-des-aliments/Batteur/csc/HandMixer",
                    videoUrl: "https://www.youtube.com/watch?v=ysscUgy1geU"
                )
            ],
            creationDate: nil,
            isD2CVisible: true
        )
    }
}

extension Kitchenware: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(key)
    }
}

public extension Kitchenware {
    static func inPack(kitchenwares: [Kitchenware], forApplianceGroup applianceGroup: String) -> [Kitchenware] {
        return kitchenwares.filter({ kitchenware -> Bool in
            // return availability that contains at least one tupe appliance group, inPack
            kitchenware.availabilities.contains(where: { availability in
                return availability.compatibilities.contains(where: {
                    $0.applianceGroup == applianceGroup && $0.type == .inPack
                })
            })
        })
    }
    
}

extension Kitchenware {
    func toRealmObject() -> KitchenwareRealm {        
        return KitchenwareRealm(from: self)
    }
}

// MARK: - Array Extension
public extension Array where Element == Kitchenware {
    /// filter only the OUT_OF_PACK kitchenwares in an array
    var allButNotInPack: [Kitchenware] {
        return sorted().filter({ kitchenware -> Bool in
            kitchenware
                .availabilities
                .contains(where: { availability in
                    return availability
                        .compatibilities
                        .contains(where: { $0.type != .inPack })
                })
        })
    }
    
    /// filter only the IN_PACK kitchenwares in an array
    var allInPack: [Kitchenware] {
        return sorted().filter({ kitchenware -> Bool in
            kitchenware
                .availabilities
                .contains(where: { availability in
                    return availability
                        .compatibilities
                        .contains(where: { $0.type == .inPack })
                })
        })
    }
}

extension Kitchenware: Comparable {
    /// Sort the kitchenwares on their translatedName
    public static func < (lhs: Kitchenware, rhs: Kitchenware) -> Bool {
        return lhs.translatedName < rhs.translatedName
    }
    
    /// Identify a kitchenware by its key
    public static func == (lhs: Kitchenware, rhs: Kitchenware) -> Bool {
        return lhs.key == rhs.key
    }
}
