//
//  ApplianceCoreInterfaces.swift
//
//
//  Created by Samir Tiouajni on 04/06/2024.
//

import Foundation

import RxComposableArchitecture


import GSMODApplianceSelectionKit

/// The protocol to be implemented by applications & modules composable Cores.
/// Typically, we should have one Core per feature with its state, action & environment
@available(iOS, deprecated: 999, message: "Use the new TCA 1.x instead")
public protocol TCACore {
    /// The state of the feature
    associatedtype State
    /// The action of the feature
    associatedtype Action
    /// The environment of the feature
    associatedtype Environment
    
    /// Shortcut to reference the store of the feature
    typealias Store = RxComposableArchitecture.Store<State, Action>
    /// Shortcut to reference the reducer of the feature
    typealias Reducer = RxComposableArchitecture.Reducer<State, Action, Environment>
    
    /// The full reducer of the feature :
    /// will contain all the logic of the feature itself and its dependencies
    /// Should not be used directly. Use `reducer` methods instead
    static var featureReducer: Reducer { get }
}


public protocol ApplianceCoreInterfaces {
    associatedtype KitchenwareDetailCore: ApplianceKitchenwareDetailCoreItf 
        where KitchenwareDetailCore.Environment.BaseEnvironment == BaseEnvironment
    associatedtype BaseEnvironment: ApplianceBaseEnvironmentProtocol
}

public protocol ApplianceKitchenwareDetailCoreItf: TCACore
where State: ApplianceKitchenwareDetailStateItf,
      Action: Equatable,
      Environment: ApplianceKitchenwareDetailEnvironmentItf {
}

public struct KitchenwareDetailConfiguration: Equatable {
    public let kitchenwareId: String
    public let kitchenwareName: String
    public let kitchenwareShopURL: URL?
    public let media: Media?
    
    public init(
        kitchenwareId: String,
        kitchenwareName: String,
        kitchenwareShopURL: URL?,
        media: Media?
    ) {
        self.kitchenwareId = kitchenwareId
        self.kitchenwareName = kitchenwareName
        self.kitchenwareShopURL = kitchenwareShopURL
        self.media = media
    }
}

public protocol ApplianceKitchenwareDetailStateItf: Equatable {
    static func initial(
        kitchenwareDetailConfiguration: KitchenwareDetailConfiguration
    ) -> Self
}

public protocol ApplianceKitchenwareDetailEnvironmentItf {
    
    associatedtype BaseEnvironment: ApplianceBaseEnvironmentProtocol
    
    static func live(base: BaseEnvironment) -> Self
    
    static func mock(
        servicesFactory: ApplianceServicesFactory,
        base: BaseEnvironment
    ) -> Self
}

public protocol ApplianceBaseEnvironmentProtocol {
//    var webclient: DCPWebClient! { get }
    var locale: GSLocale { get }
}
