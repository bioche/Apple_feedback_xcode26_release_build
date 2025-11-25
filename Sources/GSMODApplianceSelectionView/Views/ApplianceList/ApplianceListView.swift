//
//  ApplianceListView.swift
//  GSMODApplianceSelection
//
//  Created by Thibault POUJAT on 05/09/2025.
//

import SwiftUI
import RxComposableArchitecture

import GSMODApplianceSelectionKit
import GSMODApplianceSelectionComposableInterfaces


private typealias Ids = AccessibilityIds
private typealias Localized = ApplianceSelectionLocalized.ApplianceFirstSelection

struct ApplianceListView<ViewFactory: ApplianceViewFactoryProtocol>: View {

    let store: ApplianceListCore<ViewFactory.Cores>.Store

    var body: some View {
     EmptyView()
    }
}
