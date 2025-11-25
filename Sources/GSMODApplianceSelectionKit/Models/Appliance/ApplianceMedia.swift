//
//  ApplianceMedia.swift
//  GSMODApplianceSelectionKit
//
//  Created by Olivier Tavel on 24/06/2019.
//  Copyright © 2019 groupeseb. All rights reserved.
//

import Foundation

struct ApplianceMedia: Decodable {
    let id: String
    let thumbs: String?
    let isCoverMedia: Bool?
}
