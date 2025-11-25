//
//  MediaApplianceRealm.swift
//  GSMODApplianceSelectionKit
//
//  Created by Olivier Tavel on 25/06/2019.
//  Copyright © 2019 groupeseb. All rights reserved.
//

import Foundation




import Realm
import RealmSwift

class MediaApplianceRealm: Object {
    @objc dynamic var keyRealm: String?
    @objc dynamic var typeRealm: String?
    @objc dynamic var originalRealm: String?
    @objc dynamic var thumbnailRealm: String?
    @objc dynamic var originalFilenameRealm: String?
    let isDisabledRealm = RealmProperty<Bool?>()
    @objc dynamic var mediaMetadataRealm: MediaApplianceMetadataRealm?
    
    required convenience init(from media: Media) {
        self.init()
        
        keyRealm = media.key
        typeRealm = media.type
        originalRealm = media.original
        thumbnailRealm = media.thumbnail
        originalFilenameRealm = media.originalFilename
        isDisabledRealm.value = media.isDisabled
        
        if let mediaMetadata = media.mediaMetadata {
            mediaMetadataRealm = MediaApplianceMetadataRealm(from: mediaMetadata)
        }
    }
    
    func toMedia() -> Media {
        return Media(key: keyRealm,
                     type: typeRealm,
                     original: originalRealm,
                     thumbnail: thumbnailRealm,
                     originalFilename: originalFilenameRealm,
                     isDisabled: isDisabledRealm.value,
                     mediaMetadata: mediaMetadataRealm?.toMediaMetadata())
    }
}

extension MediaApplianceRealm: CascadeDeletable {
    var propertiesToCascadeDelete: [String] {
        return ["mediaMetadataRealm"]
    }
}
