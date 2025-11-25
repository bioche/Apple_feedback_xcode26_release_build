//
//  ValidationButtonView.swift
//
//
//  Created by Samir Tiouajni on 29/05/2024.
//

import SwiftUI


struct ValidationButtonView: View {
    
    let title: String
    let accessibilityId: String
    let onTap: (() -> Void)
    
    var body: some View {
        Button(action: {
            onTap()
        }) {
            Text(title)
//                .foreground(\.accentReverseColor)
//                .background(Color(\.accentMainColor))
                .frame(maxWidth: .infinity)
                .clipShape(Capsule())
        }
//        .buttonType(.floating)
        .accessibility(identifier: accessibilityId)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
}
