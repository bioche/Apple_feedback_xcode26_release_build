//
//  ClassificationRealm.swift
//  GSMODApplianceSelectionKit
//
//  Created by Olivier Tavel on 25/06/2019.
//  Copyright © 2019 groupeseb. All rights reserved.
//

import Foundation



import RealmSwift

class ClassificationRealm: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var name: String?
    @objc dynamic var type: String?
    @objc dynamic var typeId: String?
    @objc dynamic var resourceUri: String?
    
    required convenience init(from classification: Classification) {
        self.init()
        self.id = classification.id
        self.name = classification.name
        self.type = classification.type
        self.typeId = classification.typeId
        self.resourceUri = classification.resourceUri
    }
    
    func toClassification() -> Classification {
        return Classification(
            id: id,
            name: name,
            type: type,
            typeId: typeId,
            resourceUri: resourceUri
        )
    }
}
