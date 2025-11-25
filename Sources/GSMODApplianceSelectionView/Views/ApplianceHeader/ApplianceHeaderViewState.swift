//
//  ApplianceHeaderViewState.swift
//
//
//  Created by Samir Tiouajni on 01/06/2024.
//

import Foundation

struct ApplianceHeaderViewState: Equatable {
    let applianceNickname: String
    let domainName: String
    let mediaUrl: String?
    let isLoading: Bool
}

extension ProductDetailsCore.State {
    var applianceHeaderView: ApplianceHeaderViewState {
        .init(
            applianceNickname: applianceNickname, 
            domainName: domainName,
            mediaUrl: selectedAppliance?.urlMedia?.absoluteString,
            isLoading: isNicknameEditing
        )
    }
}

extension ApplianceDeclarationCore.State {
    var applianceHeaderView: ApplianceHeaderViewState {
        .init(
            applianceNickname: applianceNickname, 
            domainName: domainName,
            mediaUrl: chosenAppliance.media,
            isLoading: false
        )
    }
}
