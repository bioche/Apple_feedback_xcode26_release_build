//
//  MediaResponseApplianceRealm.swift
//  GSMODApplianceSelectionKit
//
//  Created by Olivier Tavel on 25/06/2019.
//  Copyright © 2019 groupeseb. All rights reserved.
//

import Foundation




import Realm
import RealmSwift

class MediaResponseApplianceRealm: Object {
    @objc dynamic var captionTextRealm: String?
    @objc dynamic var captionTitleRealm: String?
    @objc dynamic var identifierRealm: String?
    let isCoverRealm = RealmProperty<Bool?>()
    @objc dynamic var mediaRealm: MediaApplianceRealm?
    
    required convenience init(from mediaResponse: MediaResponse) {
        self.init()
        
        captionTextRealm = mediaResponse.captionText
        captionTitleRealm = mediaResponse.captionTitle
        identifierRealm = mediaResponse.identifier
        isCoverRealm.value = mediaResponse.isCover
        
        if let media = mediaResponse.media {
            mediaRealm = MediaApplianceRealm(from: media)
        }
    }
    
    func toMediaResponse() -> MediaResponse {
        return MediaResponse(identifier: identifierRealm,
                             isCover: isCoverRealm.value,
                             media: mediaRealm?.toMedia(),
                             captionTitle: captionTitleRealm,
                             captionText: captionTextRealm)
    }
}

extension MediaResponseApplianceRealm: CascadeDeletable {
    var propertiesToCascadeDelete: [String] {
        return ["mediaRealm"]
    }
}
