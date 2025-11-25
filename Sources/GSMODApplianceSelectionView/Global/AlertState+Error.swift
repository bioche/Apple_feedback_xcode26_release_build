//
//  AlertState+Error.swift
//  
//
//  Created by Eric BLACHERE on 08/09/2022.
//

import Foundation

import RxComposableArchitecture

extension RxComposableArchitecture.AlertState {
    static func defaultError(acknowledge: Action) -> Self {
         .init(
             title: String(gsLocalized: "applianceselection_detail_generic_error_title"),
             message: String(gsLocalized: "applianceselection_detail_generic_error_message"),
             dismissButton: .cancel()
         )
     }
}
