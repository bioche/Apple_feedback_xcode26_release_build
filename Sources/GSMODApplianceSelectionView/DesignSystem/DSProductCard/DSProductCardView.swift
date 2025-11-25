//
//  DSProductCardView.swift
//  CookEat
//
//  Created by Samir Tiouajni on 12/03/2022.
//  Copyright © 2022 SEB. All rights reserved.
//

import SwiftUI

import RxComposableArchitecture
import GSMODApplianceSelectionKit

private typealias Ids = DSProductCardIds

public struct DSProductCardView: View {
    
    let applianceName: String
    let connectionState: ConnectionState?
    let selectedKitchenwares: String?
    let capacityDescription: String?
    let imageURLPath: URL?
    let onTap: () -> Void
    
    public init(
        name: String,
        connectionState: ConnectionState?,
        selectedKitchenwares: String?,
        capacityDescription: String?,
        imageURLPath: URL?,
        onTap: @escaping () -> Void
    ) {
        self.applianceName = name
        self.connectionState = connectionState
        self.selectedKitchenwares = selectedKitchenwares
        self.capacityDescription = capacityDescription
        self.imageURLPath = imageURLPath
        self.onTap = onTap
    }
    
    public var body: some View {
        
        EmptyView()
    }
    
}
