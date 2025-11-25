//
//  ProductPairingCardView.swift
//
//
//  Created by Samir Tiouajni on 03/06/2024.
//


import SwiftUI

import GSMODApplianceSelectionComposableInterfaces
import RxComposableArchitecture

private typealias Localized = ApplianceSelectionLocalized.ProductDetails.CardProductPairing

struct ProductPairingCardView<ViewFactory: ApplianceViewFactoryProtocol>: View {
    
    let store: ProductDetailsCore<ViewFactory.Cores>.Store
    
    var body: some View {
     EmptyView()
    }
}
