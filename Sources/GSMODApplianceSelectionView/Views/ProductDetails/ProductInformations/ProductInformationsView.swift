//
//  ProductInformationsView.swift
//  
//
//  Created by Samir Tiouajni on 01/04/2022.
//


import SwiftUI

import GSMODApplianceSelectionComposableInterfaces
import RxComposableArchitecture

private typealias Localized = ApplianceSelectionLocalized.ProductDetails

struct ProductInformationsView<ViewFactory: ApplianceViewFactoryProtocol>: View {
    
    let store: ProductDetailsCore<ViewFactory.Cores>.Store
    
    var body: some View {
     EmptyView()
    }
}
