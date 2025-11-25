//
//  ApplianceServicesFactory.swift
//  GSMODApplianceSelectionKit
//
//  Created by Olivier Tavel on 04/07/2019.
//  Copyright © 2019 groupeseb. All rights reserved.
//

import Foundation

import RxSwift

/// The factory for all services contained in the kit
public protocol ApplianceServicesFactory {

    var configuration: ApplianceConfiguration { get }

    /// Handle SAV help when content AFTER_SALES == "published"
    var fetchSAVUrlPath: (() -> Observable<String?>)? { get }

    var userProductsService: UserProductsService { get }

    func buildAppliancesService() -> AppliancesService

    func buildSelectedAppliancesService() -> SelectedAppliancesService

    func buildKitchenwaresService() -> KitchenwaresService

    func buildMigrationStoreService() -> MigrationStoreService

    var autoDetectionService: AutoDetectionService? { get }
}

public struct ApplianceDefaultServicesFactory: ApplianceServicesFactory {
    public let configuration: ApplianceConfiguration
    public let userProductsService: UserProductsService
    public let fetchSAVUrlPath: (() -> Observable<String?>)?
    public var autoDetectionService: AutoDetectionService?

    public init(
        configuration: ApplianceConfiguration,
        userProductsService: UserProductsService,
        fetchSAVUrlPath: (() -> Observable<String?>)? = nil,
        autoDetectionService: AutoDetectionService?
    ) {
        self.configuration = configuration
        self.userProductsService = userProductsService
        self.fetchSAVUrlPath = fetchSAVUrlPath
        self.autoDetectionService = autoDetectionService
    }

    public func buildAppliancesService() -> AppliancesService {
        AppliancesRepository(
            network: buildApplianceNetworkService(),
            persistentStore: buildApplianceCachePersistentStore(),
            locale: configuration.locale,
            syncType: configuration.syncType
        )
    }

    public func buildSelectedAppliancesService() -> SelectedAppliancesService {
        return SelectedAppliancesRepository(
            persistentStore: SelectedAppliancesPersistentStore(
                realmInstanceProvider: SelectedAppliancesRealmInstanceProvider()
            ),
            appliancesService: buildAppliancesService(),
            kitchenwaresService: buildKitchenwaresService(),
            userProductsService: userProductsService)
    }

    public func buildKitchenwaresService() -> KitchenwaresService {
        KitchenwaresRepository(
            network: MockKitchenwaresNetwork(kitchenwaresResult: .success([])),
            persistentStore: buildApplianceCachePersistentStore(),
            locale: configuration.locale
        )
    }

    public func buildMigrationStoreService() -> MigrationStoreService {
        MigrationStoreRepository(
            persistentStore: SelectedAppliancesPersistentStore(
                realmInstanceProvider: SelectedAppliancesRealmInstanceProvider()
            ),
            appliancesService: buildAppliancesService(),
            userProductsService: userProductsService,
            selectedAppliancesService: buildSelectedAppliancesService()
        )
    }

    private func buildApplianceNetworkService() -> AppliancesAPIService {
        MockApplianceNetwork()
    }

    private func buildApplianceCachePersistentStore() -> AppliancesCachePersistentStore {
        AppliancesCachePersistentStore(realmInstanceProvider: AppliancesCacheRealmInstanceProvider())
    }
}

// Temporary live init while this isn't a struct service
public func liveKitchenwaresService(
                                    locale: GSLocale) -> KitchenwaresService {
    KitchenwaresRepository(
        network: MockKitchenwaresNetwork(kitchenwaresResult: .success([])),
        persistentStore: AppliancesCachePersistentStore(realmInstanceProvider: AppliancesCacheRealmInstanceProvider()),
        locale: locale
    )
}

// Temporary live init while this isn't a struct service
public func liveSelectedApplianceService(
    locale: GSLocale,
    syncType: SyncType,
    userProductsService: UserProductsService
) -> SelectedAppliancesService {
    SelectedAppliancesRepository(
        persistentStore: SelectedAppliancesPersistentStore(
            realmInstanceProvider: SelectedAppliancesRealmInstanceProvider()
        ),
        appliancesService: AppliancesRepository(
            network: MockApplianceNetwork(),
            persistentStore: AppliancesCachePersistentStore(
                realmInstanceProvider: AppliancesCacheRealmInstanceProvider()
            ),
            locale: locale,
            syncType: syncType
        ),
        kitchenwaresService: liveKitchenwaresService(locale: locale),
        userProductsService: userProductsService
    )
}
