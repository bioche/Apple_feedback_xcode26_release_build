//
//  MediaApplianceMetadataRealm.swift
//  GSMODApplianceSelectionKit
//
//  Created by Olivier Tavel on 25/06/2019.
//  Copyright © 2019 groupeseb. All rights reserved.
//

import Foundation



import Realm
import RealmSwift

class MediaApplianceMetadataRealm: Object {
    let widthRealm = RealmProperty<Int?>()
    let heightRealm = RealmProperty<Int?>()
    let sizeRealm = RealmProperty<Int?>()
    let lengthRealm = RealmProperty<Int?>()
    @objc dynamic var mimeTypeRealm: String?
    
    required convenience init(from mediaMetadata: MediaMetadata) {
        self.init()
        
        widthRealm.value = mediaMetadata.width
        heightRealm.value = mediaMetadata.height
        sizeRealm.value = mediaMetadata.size
        lengthRealm.value = mediaMetadata.length
        mimeTypeRealm = mediaMetadata.mimeType
    }
    
    func toMediaMetadata() -> MediaMetadata {
        return MediaMetadata(width: widthRealm.value,
                             height: heightRealm.value,
                             size: sizeRealm.value,
                             length: lengthRealm.value,
                             mimeType: mimeTypeRealm)
    }
}
