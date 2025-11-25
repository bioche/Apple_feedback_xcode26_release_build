//
//  KitchenwareList.swift
//  GSMODApplianceSelectionKit
//
//  Created by Olivier Tavel on 12/08/2019.
//  Copyright © 2019 groupeseb. All rights reserved.
//

import Foundation





/// Only purpose of this is to be cached.
/// Stored with the appliance group & locale so that it can be identified from other cached lists.
struct KitchenwaresList {
    let kitchenwares: [Kitchenware]
    let cacheId: String
}

extension KitchenwaresList {
    init(kitchenwares: [Kitchenware], locale: GSLocale, applianceGroup: String) {
        self.init(kitchenwares: kitchenwares, cacheId: KitchenwaresQueryBundle.id(locale: locale, applianceGroup: applianceGroup))
    }
}

extension KitchenwaresList: CachedRealm {
    func toRealmObject() -> CachedRealmObject {
        KitchenwaresListRealm(from: self)
    }
}
