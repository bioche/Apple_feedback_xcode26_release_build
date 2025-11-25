//
//  DSStatusConnectionView.swift
//
//
//  Created by Samir Tiouajni on 26/04/2024.
//

import SwiftUI



private typealias Ids = DSProductCardIds

public struct ConnectionState: Equatable {
    public let text: String
//    public let image: GSImageSource
    public let borderColor: Color
    
    public init(text: String,/* image: GSImageSource,*/ borderColor: Color) {
        self.text = text
//        self.image = image
        self.borderColor = borderColor
    }
}

public struct DSStatusConnectionView: View {
    
    let connectionState: ConnectionState
    
    public init(connectionState: ConnectionState) {
        self.connectionState = connectionState
    }
    
    public var body: some View {
       EmptyView()
    }
}
