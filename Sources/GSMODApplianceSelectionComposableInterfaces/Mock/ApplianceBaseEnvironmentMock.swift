//
//  File.swift
//  
//
//  Created by Eric BLACHERE on 14/06/2024.
//

import Foundation

import GSMODApplianceSelectionKit

public struct ApplianceBaseEnvironmentMock: ApplianceBaseEnvironmentProtocol {
    public var locale: GSLocale
    
    public init(locale: GSLocale) {
//        self.webclient = webclient
        self.locale = locale
    }
}
