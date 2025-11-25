//
//  ApplianceHeaderViewAction.swift
//
//
//  Created by Samir Tiouajni on 01/06/2024.
//

import Foundation

enum ApplianceHeaderViewAction: Equatable {
    case saveNickname
    case updateNickname(String)
    case setNickName(Bool)
}

extension ProductDetailsCore.Action {
    static func fromView(_ viewAction: ApplianceHeaderViewAction) -> Self {
        switch viewAction {
        case .saveNickname:
            return .saveNickname
            
        case .setNickName(let isEditing):
            return .setNickName(isEditing)
            
        case .updateNickname(let nickname):
            return .updateNickname(nickname)
        }
    }
}

extension ApplianceDeclarationCore.Action {
    static func fromView(_ viewAction: ApplianceHeaderViewAction) -> Self {
        switch viewAction {
        case .saveNickname:
            return .saveNickname
            
        case .setNickName(let isEditing):
            return .setNickName(isEditing)
            
        case .updateNickname(let nickname):
            return .updateNickname(nickname)
        }
    }
}
