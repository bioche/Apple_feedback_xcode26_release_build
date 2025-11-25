//
//  SwiftUIView.swift
//  
//
//  Created by Thibault POUJAT on 25/05/2022.
//

import SwiftUI



struct KitchenwareCellView: View {
    
    struct ViewState: Identifiable, Equatable {
        var id: String
        var title: String
//        var imageSource: GSImageSource?
        var displayOverlay: Bool
        
        struct DisclosureImage: Equatable {
            var name: String
            var color: Color
        }
        let disclosureImage: DisclosureImage?
        
        init(_ cellModel: KitchenwareCellModel) {
            self.id = cellModel.key
            self.title = cellModel.translatedName
//            self.imageSource = .url(cellModel.imageURL)
            self.displayOverlay = cellModel.isSelected
            
            switch cellModel.disclosureType {
            case .arrow:
                self.disclosureImage = .init(
                    name: KitchenwareListImageName.icArrow,
                    color: Color.black
                )
            case .info:
                self.disclosureImage = .init(
                    name: KitchenwareListImageName.icInfo,
                    color: Color.black
                )
            case .none:
                self.disclosureImage = nil
            }
        }
    }
    
    let viewState: ViewState
    var didTapDisclosureButton: () -> Void
    var didTapCell: () -> Void
    
    var body: some View {
     EmptyView()
    }
}
