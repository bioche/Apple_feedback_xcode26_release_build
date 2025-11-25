//
//  KitchenwareLocalizedUrlRealm.swift
//  
//
//  Created by Aurélien GRIFASI on 06/12/2023.
//

import Foundation



import RealmSwift

class KitchenwareLocalizedUrlRealm: Object {

    @objc dynamic var redirectionUrl: String?
    @objc dynamic var videoUrl: String?

    required convenience init(from localizedUrl: KitchenwareLocalizedUrl) {
        self.init()
        
        self.redirectionUrl = localizedUrl.redirectionUrl
        self.videoUrl = localizedUrl.videoUrl
    }

    func toKitchenwareLocalizedUrl() -> KitchenwareLocalizedUrl {
        KitchenwareLocalizedUrl(redirectionUrl: redirectionUrl, videoUrl: videoUrl)
    }
}
