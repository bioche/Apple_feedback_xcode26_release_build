//
//  RealmInstanceProvidingService.swift
//  GSMODApplianceSelectionKit
//
//  Created by Eric Blachère on 21/11/2019.
//  Copyright © 2019 groupeseb. All rights reserved.
//

import Foundation

import RealmSwift
import SwiftyBeaver

struct AppliancesCacheRealmInstanceProvider: PersistingRealmInstanceProvidingService {
    
    let location = Location(databaseName: "GSMODAppliance.appliances.realm", folderURL: nil)
    let deleteRealmIfMigrationNeeded = true
    var configuration: Realm.Configuration?
    var schemaVersion: UInt64 { 3 }
    let realmEntities = [
        ApplianceSyncResponseRealm.self,
        ApplianceRealm.self,
        ClassificationRealm.self,
        ApplianceCapacityRealm.self,
        GroupRealm.self,
        ApplianceFamilyRealm.self,
        KitchenwaresListRealm.self,
        KitchenwareRealm.self,
        KitchenwareAvailabilityRealm.self,
        KitchenwareCompatibilityRealm.self,
        KitchenwareLocalizedUrlRealm.self,
        MediaApplianceRealm.self,
        MediaResponseApplianceRealm.self,
        MediaApplianceMetadataRealm.self
    ]
}
 
struct SelectedAppliancesRealmInstanceProvider: PersistingRealmInstanceProvidingService {
    var configuration: Realm.Configuration?
    let realmEntities: [Object.Type]
    let location: Location
    var schemaVersion: UInt64 { 1 }
    
    init() {
        self.location = Location(
            databaseName: "SelectedAppliances.realm",
            folderURL: URL(string: "")!
        )
        self.realmEntities = [
            SelectedApplianceRealm.self,
            ApplianceCapacityRealm.self
        ]
    }
}

/// The protocol implemented by providers that actually persist data between launches.
/// Its default implementation of `realmInstance()` creates Realm instance from stored configurations & clears database on error.
public protocol PersistingRealmInstanceProvidingService: RealmInstanceProvidingService {
    /// The list of the entities handled by the database. New models have to be added there.
    var realmEntities: [Object.Type] { get }
    /// The list of embedded entities handled by the database. New embedded models have to be added there.
    ///
    /// ⚠️ switching from standard to embedded object requires to increment `schemaVersion` and
    /// modifying existing `migrationBlock`
    var realmEmbeddedEntities: [EmbeddedObject.Type] { get }
    /// The current version of the Realm model (default is 0)
    var schemaVersion: UInt64 { get }
    /// Usually nothing to do for small changes. (default does nothing)
    var migrationBlock: MigrationBlock { get }
    /// True if the whole database can be dropped on realm model update (default is false)
    var deleteRealmIfMigrationNeeded: Bool { get }
    /// Current database location
    var location: Location { get }
    /// Creates the configuration of the Realm database. Override this if you wish to customize the configuration beyond the properties above.
    ///
    /// - Returns: The Realm configuration
    /// - Throws: RealmInstanceProviderError
    func buildConfiguration() throws -> Realm.Configuration
}

public extension PersistingRealmInstanceProvidingService {
    var migrationBlock: MigrationBlock {
        return { (_, _) in }
    }
    
    var deleteRealmIfMigrationNeeded: Bool { false }
    
    var schemaVersion: UInt64 { 0 }
    
    var realmEmbeddedEntities: [EmbeddedObject.Type] { [] }
    
    func realmInstance() throws -> Realm {
        
        let configuration = try getConfiguration()
        do {
            return try Realm(configuration: configuration)
        } catch {
            SwiftyBeaver.self.error("The database seems corrupted or has been imported from another application. An error will be thrown & the database will be dropped for future retries. Reason : \(error)")
            clearDatabase()
            throw RealmInstanceProviderError.realmInstanceCreation(reason: error)
        }
    }
    
    private func clearDatabase() {
        do {
            if FileManager.default.fileExists(atPath: location.realmFileURL.path) {
                SwiftyBeaver.self.info("Removing database.")
                try FileManager.default.removeItem(at: location.realmFileURL)
            }
        } catch {
            SwiftyBeaver.self.error("Unable to clear database : \(error)")
        }
    }
    
    func buildConfiguration() throws -> Realm.Configuration {
        Realm.Configuration(fileURL: location.realmFileURL,
                            schemaVersion: schemaVersion,
                            migrationBlock: migrationBlock,
                            deleteRealmIfMigrationNeeded: deleteRealmIfMigrationNeeded,
                            objectTypes: realmEntities + realmEmbeddedEntities)
    }
    
    /// Creates & stores the configuration if not stored yet.
    /// Returns the stored configuration.
    func getConfiguration() throws -> Realm.Configuration {
        if let configuration = RealmConfigurationsStore.configurations[location] {
            return configuration
        }
        let conf = try buildConfiguration()
        RealmConfigurationsStore.configurations[location] = conf
        return conf
    }
    
    /// Alters the configuration in case you want to make a dynamic change. Future calls to `realmInstance` function will take that into account.
    /// - Parameter alteration: The alteration to be performed
    func alterConfiguration(_ alteration: (Realm.Configuration) throws -> Realm.Configuration) throws {
        let configuration = try getConfiguration()
        let newConfiguration = try alteration(configuration)
        RealmConfigurationsStore.configurations[location] = newConfiguration
    }
}

/// Stores the configurations as their creation is costly.
struct RealmConfigurationsStore {
    // We allow nonisolated(unsafe) as the days of Realm are numbered ;)
    nonisolated(unsafe) static var configurations = [Location: Realm.Configuration]()
}

public struct Location: Hashable {
    /// The name of the database file
    public var databaseName: String
    /// The app group identifier to use to share data
    public var folderURL: URL
    
    public var realmFileURL: URL {
        
        let realmFileURL = folderURL.appendingPathComponent(databaseName)
        
        if !FileManager.default.fileExists(atPath: folderURL.path) {
            do {
                try FileManager.default.createDirectory(
                    at: folderURL,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
            } catch {
                assertionFailure("GSMODRealmPersistenceHelper - Fail to create intermediate directories")
            }
        }
        
        return realmFileURL
    }
    
    public init(
        databaseName: String,
        folderURL: URL?
    ) {
        self.databaseName = databaseName
        self.folderURL = folderURL ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
