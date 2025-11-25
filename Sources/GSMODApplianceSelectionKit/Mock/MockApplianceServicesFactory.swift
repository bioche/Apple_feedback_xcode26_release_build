//
//  ServicesFactoryStub.swift
//  GSMODApplianceSelectionKit
//
//  Created by Olivier Tavel on 28/08/2019.
//  Copyright © 2019 groupeseb. All rights reserved.
//

import Foundation

import RxSwift
import RealmSwift

/// Provides instance of a Realm stored in memory instead of disk.
/// It means data will be lost between app launches.
/// You can have as many instances of this struct as the realms are kept statically.
public struct InMemoryRealmInstanceProvider: RealmInstanceProvidingService {
    /// We MUST keep a strong reference to the realms inMemory.
    /// Otherwise Realms get deallocated & we lose all data
    /// We allow nonisolated(unsafe) as the days of Realm are numbered ;)
    nonisolated(unsafe) static var realms = [String: Realm]()
    
    let identifier: String
    
    public init(identifier: String) {
        self.identifier = identifier
    }
    
    public func realmInstance() throws -> Realm {
        if let realm = InMemoryRealmInstanceProvider.realms[identifier] {
            return realm
        }
        let realm = try Realm(configuration: Realm.Configuration(inMemoryIdentifier: identifier))
        InMemoryRealmInstanceProvider.realms[identifier] = realm
        return realm
    }
}

public enum RealmInstanceProviderError: Error {
    case realmInstanceCreation(reason: Error)
}

/// The service providing a Realm instance. You can either use `InMemoryRealmInstanceProvider` (for TUs mostly) or implement `PersistingRealmInstanceProvidingService`.
public protocol RealmInstanceProvidingService {
    /// Gives a Realm instance.
    /// Can be called as much as needed without affecting performance.
    /// No need to keep references to the Realms otherwise you expose yourself to multi-thread crashes :'(
    ///
    /// - Returns: A Realm instance
    /// - Throws: RealmInstanceProviderError
    func realmInstance() throws -> Realm
}

public struct MockApplianceServicesFactory: ApplianceServicesFactory {

    let selectedAppliancesPersistentStore = SelectedAppliancesPersistentStore(
        realmInstanceProvider: InMemoryRealmInstanceProvider(identifier: "SelectedAppliances")
    )
    let appliancesCachePersistentStore = AppliancesCachePersistentStore(
        realmInstanceProvider: InMemoryRealmInstanceProvider(identifier: "AppliancesCache")
    )
    
    public let configuration: ApplianceConfiguration
    public let userProductsService: UserProductsService
    public let kitchenwaresNetworkService: MockKitchenwaresNetwork
    public var fetchSAVUrlPath: (() -> Observable<String?>)?
    public var autoDetectionService: AutoDetectionService?

    public init(
        configuration: ApplianceConfiguration,
        kitchenwaresNetworkService: MockKitchenwaresNetwork,
        fetchSAVUrlPath: (() -> Observable<String?>)?
    ) {
        self.configuration = configuration
        self.userProductsService = MockUserProductsGateway()
        self.kitchenwaresNetworkService = kitchenwaresNetworkService
        self.fetchSAVUrlPath = fetchSAVUrlPath
        self.autoDetectionService = MockAutoDetectionService()
    }
    
    public init(
        kitchenwaresNetworkService: MockKitchenwaresNetwork,
        fetchSAVUrlPath: (() -> Observable<String?>)?
    ) {
        configuration = .mock()
        userProductsService = MockUserProductsGateway()
        self.kitchenwaresNetworkService = kitchenwaresNetworkService
        self.fetchSAVUrlPath = fetchSAVUrlPath
    }
    
    public func buildAppliancesService() -> AppliancesService {
        buildAppliancesService(simulateFailedRequest: false)
    }
    
    public func buildMigrationStoreService() -> MigrationStoreService {
        buildMigrationStoreService(simulateFailedRequest: false)
    }
    
    public func buildSelectedAppliancesService() -> SelectedAppliancesService {
        buildSelectedAppliancesService(simulateFailedRequest: false)
    }
    
    public func buildKitchenwaresService() -> KitchenwaresService {
        KitchenwaresRepository(
            network: buildKitchenwaresNetworkService(),
            persistentStore: appliancesCachePersistentStore,
            locale: configuration.locale
        )
    }
    
    func buildAppliancesService(simulateFailedRequest: Bool = false) -> AppliancesService {
        AppliancesRepository(
            network: buildApplianceNetworkService(simulateFailedRequest: simulateFailedRequest),
            persistentStore: appliancesCachePersistentStore,
            locale: configuration.locale,
            syncType: configuration.syncType
        )
    }
    
    func buildSelectedAppliancesService(
        simulateFailedRequest: Bool = false,
        userProductsService: UserProductsService = MockUserProductsGateway()
    ) -> SelectedAppliancesService {
        SelectedAppliancesRepository(
            persistentStore: selectedAppliancesPersistentStore,
            appliancesService: buildAppliancesService(simulateFailedRequest: simulateFailedRequest),
            kitchenwaresService: buildKitchenwaresService(),
            userProductsService: userProductsService
        )
    }
    
    func buildMigrationStoreService(
        simulateFailedRequest: Bool = false,
        userProductsService: UserProductsService = MockUserProductsGateway()
    ) -> MigrationStoreService {
        MigrationStoreRepository(
            persistentStore: selectedAppliancesPersistentStore,
            appliancesService: buildAppliancesService(simulateFailedRequest: simulateFailedRequest),
            userProductsService: userProductsService,
            selectedAppliancesService: buildSelectedAppliancesService(
                simulateFailedRequest: simulateFailedRequest,
                userProductsService: userProductsService
            )
        )
    }
        
    func buildApplianceNetworkService(simulateFailedRequest: Bool = false) -> AppliancesAPIService {
        MockApplianceNetwork(simulateFailedRequest: simulateFailedRequest)
    }
    
    public func buildKitchenwaresNetworkService() -> KitchenwaresNetworkService {
        kitchenwaresNetworkService
    }
    
    func cleanAppliancesCache() {
        do {
            let realm = try appliancesCachePersistentStore.realmInstance()
            try realm.write {
                realm.deleteAll()
            }
        } catch {
            
        }
    }
}
