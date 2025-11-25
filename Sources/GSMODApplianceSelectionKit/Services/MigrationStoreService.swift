//
//  MigrationStoreService.swift
//  GSMODApplianceSelectionKit
//
//  Created by sebastien lablanchy on 28/01/2020.
//  Copyright © 2020 SEB. All rights reserved.
//

import Foundation

import RxSwift

/// Allows the products creation when internal storage is source of truth
public protocol MigrationStoreService {
    
    /// Allows the products creation when internal storage is source of truth
    func requestProductsCreationFromLocalStore() -> Observable<[UserProduct]>
    
}
