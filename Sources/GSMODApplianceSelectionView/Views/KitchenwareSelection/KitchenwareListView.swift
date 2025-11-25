//
//  SwiftUIView.swift
//  
//
//  Created by Thibault POUJAT on 16/05/2022.
//

import SwiftUI

import GSMODApplianceSelectionComposableInterfaces

import RxComposableArchitecture

import GSMODApplianceSelectionKit


public enum DisclosureType: String {
    case info, arrow, none
}

private typealias Localized = ApplianceSelectionLocalized.KitchenwareList

public struct KitchenwareListView<ViewFactory: ApplianceViewFactoryProtocol>: View {
    let store: KitchenwareListCore<ViewFactory.Cores>.Store
    
    public init(store: KitchenwareListCore<ViewFactory.Cores>.Store) {
        self.store = store
    }
    
    public var body: some View {
     EmptyView()
    }
}

extension KitchenwareListView {
    typealias ViewAction = KitchenwareListCore<ViewFactory.Cores>.Action
}
