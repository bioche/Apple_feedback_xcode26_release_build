//
//  ApplianceFirstSelectionView.swift
//
//
//  Created by Samir Tiouajni on 03/06/2024.
//

import SwiftUI

import GSMODApplianceSelectionComposableInterfaces
import RxComposableArchitecture




private typealias Localized = ApplianceSelectionLocalized.ApplianceFirstSelection

public struct ApplianceFirstSelectionView<ViewFactory: ApplianceViewFactoryProtocol>: View {
    
    let store: ApplianceFirstSelectionCore<ViewFactory.Cores>.Store
    let wrapInNavigationStack: Bool
    let backButtonHidden: Bool
    
    public init(
        store: ApplianceFirstSelectionCore<ViewFactory.Cores>.Store,
        wrapInNavigationStack: Bool,
        backButtonHidden: Bool = true
    ) {
        self.store = store
        self.wrapInNavigationStack = wrapInNavigationStack
        self.backButtonHidden = backButtonHidden
    }
    
    public var body: some View {
     EmptyView()
    }
}
