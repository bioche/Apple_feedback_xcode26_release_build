//
//  ProductInformationCell.swift
//  
//
//  Created by Samir Tiouajni on 29/03/2022.
//

import SwiftUI


struct ProductInformationCell: View {
    
    private let title: String
    private let isClickable: Bool
    
    init(title: String, isClickable: Bool = false) {
        self.title = title
        self.isClickable = isClickable
    }
    
    var body: some View {
     EmptyView()
    }
}

struct AppliancePropertyCell_Previews: PreviewProvider {
    static var previews: some View {
        ProductInformationCell(title: "Déclarer les accessoires")
    }
}
