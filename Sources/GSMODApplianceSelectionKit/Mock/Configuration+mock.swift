//
//  Configuration+mock.swift
//  GSMODApplianceSelectionKit
//
//  Created by Eric Blachère on 18/11/2019.
//  Copyright © 2019 groupeseb. All rights reserved.
//

import Foundation

extension Dictionary where Key == RawDomain, Value == ApplianceDomainConfiguration {
    public static let mockedApplianceDomainConfigurations: [RawDomain: ApplianceDomainConfiguration] =
    ["PRO_ACT": ApplianceDomainConfiguration(name: "Actifry", iconName: "ic_recipe_actifry", order: 2),
     "PRO_KIT": ApplianceDomainConfiguration(name: "Kitchen Coach", iconName: "ic_recipe_kitchencoach", order: 3),
     "PRO_AUT": ApplianceDomainConfiguration(name: "Smart&Tasty", iconName: "ic_recipe_autocuiseur", order: 4),
     "PRO_CAK": ApplianceDomainConfiguration(name: "Cake Factory", iconName: "ic_recipe_cakefactory", order: 5),
     "PRO_COO": ApplianceDomainConfiguration(name: "Cookeo", iconName: "ic_recipe_cookeo", order: 1),
     "PRO_COM": ApplianceDomainConfiguration(name: "Companion", iconName: "ic_recipe_companion", order: 0),
     "PRO_COP": ApplianceDomainConfiguration(name: "Cooking Connect", iconName: "ic_recipe_cookingconnect", order: nil),
     "PRO_OPG": ApplianceDomainConfiguration(name: "Optigrill", iconName: "ic_recipe_optigrill", order: nil),
     "PRO_STE": ApplianceDomainConfiguration(name: "Steam Up", iconName: "ic_recipe_steamup", order: nil),
     "PRO_SOC": ApplianceDomainConfiguration(name: "Soup&Co", iconName: nil, order: 10)
    ]
}

extension ApplianceConfiguration {
    public static func mock(
        market: String = "GS_FR",
        country: String = "FR",
        language: String = "fr",
        isPremium: Bool = false,
        brandName: String = "Cookeat",
        applianceDomainConfigurations: [RawDomain: ApplianceDomainConfiguration] = .mockedApplianceDomainConfigurations
    ) -> ApplianceConfiguration {
        .init(
            locale: GSLocale(
                market: GSMarket(
                    language: language,
                    country: country,
                    name: market
                )
            ),
            syncType: .publishedOnly,
            appIdentifier: "Cookeo",
            isPremium: isPremium,
            brandName: brandName,
            applianceDomainConfigurations: applianceDomainConfigurations
        )
    }
}
