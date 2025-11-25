//
//  KitchenwareCellModel.swift
//  
//
//  Created by Thibault POUJAT on 08/06/2022.
//

import Foundation

import GSMODApplianceSelectionKit


@dynamicMemberLookup
public struct KitchenwareCellModel: Equatable {
    var disclosureType: DisclosureType
    var isSelected: Bool
    var kitchenware: Kitchenware
    
    var imageURL: URL? { kitchenware.mediaUrl() }
    
    public subscript<T>(dynamicMember keyPath: KeyPath<Kitchenware, T>) -> T {
      self.kitchenware[keyPath: keyPath]
    }
}
