//
//  UserProduct.swift
//  GSMODApplianceSelectionKit
//
//  Created by Olivier Tavel on 25/06/2019.
//  Copyright © 2019 groupeseb. All rights reserved.
//

import Foundation

public struct UserProduct: Codable {
    /// Functional identifier of product
    public var productId: ProductId
    /// Identifier of appliance
    public var applianceId: ApplianceId
    /// Firmware version of product
    public var firmwareVersion: String?
    /// Name of appliance used by User
    public var nickname: String?
    /// Capacity selected by User
    public var selectedCapacity: Capacity?
    /// Kitcehnwares id selected by User
    public var selectedKitchenwares: [KitchenwareId]
    /// The serial number of the IOT product
    public var iotSerialId: String?
    /// IoT source
    public var source: String?
    /// Product domain
    public var rawDomain: RawDomain

    /// Those dates are managed by DCP only
    public var creationDate: Date?
    public var modificationDate: Date?

    public init(
        productId: ProductId,
        applianceId: ApplianceId,
        rawDomain: RawDomain,
        firmwareVersion: String? = nil,
        nickname: String? = nil,
        selectedCapacity: Capacity? = nil,
        selectedKitchenwares: [KitchenwareId] = [],
        iotSerialId: String? = nil,
        source: String? = nil,
        creationDate: Date?,
        modificationDate: Date?
    ) {
        self.applianceId = applianceId
        self.productId = productId
        self.firmwareVersion = firmwareVersion
        self.nickname = nickname
        self.selectedCapacity = selectedCapacity
        self.selectedKitchenwares = selectedKitchenwares
        self.iotSerialId = iotSerialId
        self.source = source
        self.rawDomain = rawDomain
        self.creationDate = creationDate
        self.modificationDate = modificationDate
    }
    
    func toSelectedAppliance(appliance: Appliance) -> SelectedAppliance {
        .init(
            appliance: appliance,
            productId: productId,
            firmwareVersion: firmwareVersion,
            nickname: nickname,
            capacity: selectedCapacity,
            kitchenwares: selectedKitchenwares,
            iotSerialId: iotSerialId,
            source: source,
            creationDate: creationDate,
            modificationDate: modificationDate
        )
    }
}

extension UserProduct {
    public static func mock(id: String = UUID().uuidString) -> UserProduct {
        UserProduct(
            productId: id,
            applianceId: Appliance.stub().applianceId,
            rawDomain: "PRO_ACT",
            firmwareVersion: nil,
            nickname: nil,
            selectedCapacity: nil,
            selectedKitchenwares: [],
            iotSerialId: nil,
            source: nil,
            creationDate: Date.mock(),
            modificationDate: Date.mock()
        )
    }
    
    public static func cookeoStub() -> UserProduct {
        return UserProduct(
            productId: "PRODUCT_ID_COOKEO",
            applianceId: Appliance.cookeoStub().applianceId,
            rawDomain: "PRO_COO",
            firmwareVersion: "1.0",
            nickname: "Cookeo1",
            selectedCapacity: nil,
            selectedKitchenwares: [Kitchenware.cookeoStub().key],
            iotSerialId: "aaaa-0000-aaaaa",
            source: "IOTHUB",
            creationDate: Date.mock(),
            modificationDate: Date.mock()
        )
    }

    public static func companionStub() -> UserProduct {
        return UserProduct(
            productId: "PRODUCT_ID_COMPANION",
            applianceId: Appliance.companionStub().applianceId,
            rawDomain: "PRO_COM",
            firmwareVersion: "1.0",
            nickname: "Companion1",
            selectedCapacity: nil,
            selectedKitchenwares: [],
            iotSerialId: "bbbb-0000-bbbb",
            source: "IOTHUB",
            creationDate: Date.mock(),
            modificationDate: Date.mock()
        )
    }
    
    public static func blenderStub() -> UserProduct {
        return UserProduct(
            productId: "PRODUCT_ID_BLENDER",
            applianceId: Appliance.blenderStub().applianceId,
            rawDomain: "PRO_BLE",
            firmwareVersion: "1.0",
            nickname: "Blender1",
            selectedCapacity: nil,
            selectedKitchenwares: [],
            iotSerialId: "cccc-0000-cccc",
            source: "IOTHUB",
            creationDate: Date.mock(),
            modificationDate: Date.mock()
        )
    }
    
    public static func cakeFactoryStub() -> UserProduct {
        return UserProduct(
            productId: "PRODUCT_ID_CAKEFACTORY",
            applianceId: Appliance.cakeFactoryStub().applianceId,
            rawDomain: "PRO_CAK",
            firmwareVersion: nil,
            nickname: nil,
            selectedCapacity: nil,
            selectedKitchenwares: [Kitchenware.cakeFactoryStub().key],
            creationDate: Date.mock(),
            modificationDate: Date.mock()
        )
    }
    
    public static func aspirobotStub() -> UserProduct {
        return UserProduct(
            productId: "PRODUCT_ID_ASPIROBOT",
            applianceId: Appliance.aspirobotStub().applianceId,
            rawDomain: "PRO_ROB",
            firmwareVersion: "1.0",
            nickname: "Aspirobot1",
            selectedCapacity: nil,
            selectedKitchenwares: ["KITCHENWARE_510002"],
            iotSerialId: "aaaa-0000-aaaaa",
            source: "IOTHUB",
            creationDate: Date.mock(),
            modificationDate: Date.mock()
        )
    }
}

public extension Date {
    /// Creates a mock `Date` instance from a given string representation.
    /// - Parameter stringDate: A string representing the date and time in the format "yyyy-MM-dd-HH:mm:ss".
    ///   Defaults to "2025-08-11-12:32:56" if not provided.
    /// - Returns: A `Date` object parsed from the string, or the current date if parsing fails.
    ///
    /// The function uses the ISO 8601 calendar and the current time zone for parsing.
    /// Example usage:
    /// ```swift
    /// let date = Date.mock(stringDate: "2023-01-01-08:00:00")
    /// ```
    static func mock(_ stringDate: String = "2025-08-11-12:32:56") -> Self {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH:mm:ss"
        formatter.timeZone = .current
        formatter.calendar = Calendar(identifier: Calendar.Identifier.iso8601)

        return formatter.date(from: stringDate) ?? Date()
    }
}

public struct GSMarket: Codable, Hashable {
    /// The language of the market ("en")
    public let language: String
    /// The country of the market ("US")
    public let country: String
    /// The market name ("GS_US")
    public let name: String
    
    public init(language: String, country: String, name: String) {
        self.language = language
        self.country = country
        self.name = name
    }
    
    public static func == (lhs: GSMarket, rhs: GSMarket) -> Bool {
        lhs.language.lowercased() == rhs.language.lowercased()
            && lhs.country.lowercased() == rhs.country.lowercased()
            && lhs.name.lowercased() == rhs.name.lowercased()
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(language.lowercased())
        hasher.combine(country.lowercased())
        hasher.combine(name.lowercased())
    }
}

public struct GSLocale: Codable, Hashable {
    /// The current device locale
    static public var device: Locale {
        return Locale.current
    }
    /// The current market
    public let market: GSMarket
    /// The language direction
    public var languageDirection: Locale.LanguageDirection {
        return Locale.Language(identifier: market.language).characterDirection
    }
    
    /// The DCP ready language (ex : "fr")
    public var language: String {
        market.language
    }
    
    /// The DCP ready market name (ex : "GS_FR")
    public var marketName: String {
        market.name
    }
    
    /// The readable language ("Français")
    public var readableLanguage: String {
        guard let displayName = (associatedLocale as NSLocale).displayName(
            forKey: NSLocale.Key.languageCode,
            value: market.language) else {
                log.error("Unable to find the display name for the language \(market.language) !")
                return ""
        }
        
        return displayName.capitalized
    }
    /// The readable region ("France")
    public var readableRegion: String {
        guard let displayName = (associatedLocale as NSLocale).displayName(
            forKey: NSLocale.Key.countryCode,
            value: market.country) else {
                log.error("Unable to find the display name for the region \(market.country) !")
                return ""
        }
        
        return displayName.capitalized
    }
    /// The associated native locale
    fileprivate var associatedLocale: Locale {
        return Locale(identifier: "\(market.language)_\(market.country.uppercased())")
    }
    
    public init(market: GSMarket) {
        self.market = market
    }
}
