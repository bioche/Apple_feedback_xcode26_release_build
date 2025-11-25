//
//  AppliancesCachePersistentStore.swift
//  GSMODApplianceSelectionKit
//
//  Created by Olivier Tavel on 08/08/2019.
//  Copyright © 2019 groupeseb. All rights reserved.
//

import Foundation



import Realm
import RealmSwift
import SwiftyBeaver

struct AppliancesCachePersistentStore: CacheRealmPersistentStore {
    var cacheCompatibleTypes: [CachedRealmObject.Type] = [ApplianceSyncResponseRealm.self, KitchenwaresListRealm.self]
    var realmInstanceProvider: RealmInstanceProvidingService
    
    init(realmInstanceProvider: RealmInstanceProvidingService = AppliancesCacheRealmInstanceProvider()) {
        self.realmInstanceProvider = realmInstanceProvider
    }
    
    func deleteAll() {
        do {
            let realm = try realmInstance()
            try realm.write {
                realm.deleteAll()
            }
        } catch let error {
            log.error("error when delete all appliances cache : \(error)")
        }
    }
    
    func invalidate() {
           deleteAll()
    }
}

/// Representation of a cache persistent store, a persistent store needs to implement this protocol
public protocol CachePersistentStore {
    // MARK: - Create
    
    /// Let us save object with the corresponding cache information in the persistent store
    ///
    /// - Parameters:
    ///   - object: the object to save
    ///   - cacheInformation: the cache information to save
    ///   - completion: return a result type when the async job is done
    func save(_ object: CachedObject, with cacheInformation: CacheInformation, completion: ((CacheResult<CachedObject>) -> Void)?)
    
    // MARK: - Read
    
    /// Let us get the cache information from the persistent store
    ///
    /// - Parameters:
    ///   - queryBundle: the query that will help us track the right cache information
    ///   - completion: return the CacheResult type when the async job is complete
    func getCacheInformation(with queryBundle: QueryBundle, completion: (CacheResult<CacheInformation>) -> Void)
    
    /// Let us get an object from the persistent store
    ///
    /// - Parameters:
    ///   - cacheInformation: the cache information will help us track the right object
    ///   - completion: return a Result type when the async job is complete
    func getObject(with cacheInformation: CacheInformation, completion: (CacheResult<CachedObject>) -> Void)
    
    /// Let us get all objects with same cache policy from the persistent store
    ///
    /// - Parameters:
    ///   - cachePolicy: the cache polict will help us track the right objects
    ///   - completion: return a Result type when the async job is complete
    func getObjects(with cachePolicy: CachePolicy, completion: (CacheResult<[CachedObject]>) -> Void)
    
    // MARK: - Delete
    
    /// let us delete an object in the persistent store
    ///
    /// - Parameters:
    ///   - object: the informations that will help us track the right object
    ///   - completion: return a Result type when the async job is complete
    func delete(with cacheInformation: CacheInformation, completion: (CacheResult<Bool>) -> Void)
    
    /// Let us tell to the persistent store to delete object & cache information with cache policy
    ///
    /// - Parameters:
    ///     - cachePolicy: the cache policy to remove
    ///     - completion: return a Result type when the async job is complete
    func delete(with cachePolicy: CachePolicy, completion: (CacheResult<Bool>) -> Void)
    
    /// Let us tell to the persistent store to delete the specified cacheInformation
    ///
    /// - Parameters:
    ///     - cacheInformation: the cache information to remove
    ///     - completion: return a Result type when the async job is complete
    func dereferenceObject(with cacheInformation: CacheInformation, completion: (CacheResult<Bool>) -> Void)
    
    /// Let us tell to the persistent store to delete cache informations with the specified cache policy
    ///
    /// - Parameters:
    ///     - cachePolicy: the cache policy to remove
    ///     - completion: return a Result type when the async job is complete
    func dereferenceObjects(with cachePolicy: CachePolicy, completion: (CacheResult<Bool>) -> Void)
    
    /// Let us delete everything in current cache database
    func deleteAll()
    
    // MARK: - Cache size
    
    /// will trim the cache to the right size, respecting the cachePolicies given
    ///
    /// - Parameter cachePolicies: the different CachePolicies of the cache provider
    func trimToCacheSize(cachePolicies: [CachePolicy])
}

/// Implement this protocol to cache persistent store objects in a realm database.
public protocol CacheRealmPersistentStore: CachePersistentStore {
    // MARK: - Properties
    /// The provider of the realm instance.
    /// Use `realmInstance` directly instead of this.
    var realmInstanceProvider: RealmInstanceProvidingService { get }
    
    /// List of Realm object types will be saved in this persistant store
    /// Warning: If you forget a type object, it will not be saved or returned by persistant store
    var cacheCompatibleTypes: [CachedRealmObject.Type] { get set }
    
    // MARK: - Methods
    /// Shortcut for `try realmInstanceProvider.realmInstance()`
    func realmInstance() throws -> Realm
    
    /// Returns potential CachedRealmObject of an CachedObject
    ///
    /// - Parameter object: CachedObject will be transformed
    /// - Returns: CachedRealmObject on success, CacheRealmPersistentStoreError on error
    func cachedRealmObject(of object: CachedObject) -> Result<CachedRealmObject, CacheRealmPersistentStoreError>
    
    /// Returns potential CachedRealmObject from a cache id.
    ///
    /// - Parameter objectCacheId: Specific cache Id
    /// - Returns: CachedRealmObject on success, CacheRealmPersistentStoreError on error
    func cachedRealmObject(cacheId: String) -> Result<CachedRealmObject, CacheRealmPersistentStoreError>
}

extension CacheRealmPersistentStore {
    public func realmInstance() throws -> Realm {
        try realmInstanceProvider.realmInstance()
    }
    
    public func cachedRealmObject(of object: CachedObject) -> Result<CachedRealmObject, CacheRealmPersistentStoreError> {
        // If the object does not conform to CachedRealm protocol, we cannot use it
        guard let cachedRealm = object as? CachedRealm else {
            return .failure(CacheRealmPersistentStoreError.notSupported)
        }
        
        return .success(cachedRealm.toRealmObject())
    }
    
    public func cachedRealmObject(cacheId: String) -> Result<CachedRealmObject, CacheRealmPersistentStoreError> {
        guard let realm = try? realmInstance() else {
            return .failure(CacheRealmPersistentStoreError.realmUnavailable)
        }
        
        return {
            // For each type compatible with this persistant store, we check if one of them have an object with provided cache id
            for type in cacheCompatibleTypes {
                if let realmObject = realm.object(ofType: type, forPrimaryKey: cacheId) as? CachedRealmObject {
                    return .success(realmObject)
                }
            }
            
            return .failure(CacheRealmPersistentStoreError.notCached)
        }()
    }

    public func save(_ object: CachedObject, with cacheInformation: CacheInformation, completion: ((CacheResult<CachedObject>) -> Void)?) {
        guard let realm = try? realmInstance() else {
            completion?(.error(CacheRealmPersistentStoreError.realmUnavailable))
            return
        }
        
        let result = cachedRealmObject(of: object)
        
        switch result {
        case .success(let cachedRealmObject):
            cachedRealmObject.cacheIdentifier = cacheInformation.objectCacheId
            cachedRealmObject.cacheDate = Date()
            cachedRealmObject.cachePolicyIdentifier = cacheInformation.cachePolicyIdentifier
            
            do {
                try realm.write {
                    realm.add(cachedRealmObject, update: .all)
                }
                completion?(.success(object))
            } catch let error {
                SwiftyBeaver.self.error("Failed to save object in cache: \(error)")
                completion?(.error(error))
            }
        case .failure(let error):
            completion?(.error(error))
        }
    }
    
    public func getCacheInformation(with queryBundle: QueryBundle, completion: (CacheResult<CacheInformation>) -> Void) {
        let result = cachedRealmObject(cacheId: queryBundle.id)
        
        switch result {
        case .success(let cachedRealmObject):
            var cacheInformation = CacheInformation(cacheId: queryBundle.id, cachePolicyIdentifier: queryBundle.cachePolicyIdentifier)
            cacheInformation.creationDate = cachedRealmObject.cacheDate
            cacheInformation.lastRefreshDate = cachedRealmObject.cacheDate
            
            completion(.success(cacheInformation))
        case .failure(let error):
            completion(.error(error))
        }
    }
    
    public func getObject(with cacheInformation: CacheInformation, completion: (CacheResult<CachedObject>) -> Void) {
        let result = cachedRealmObject(cacheId: cacheInformation.objectCacheId)
        
        switch result {
        case .success(let cachedRealmObject):
            completion(.success(cachedRealmObject.toObject()))
        case .failure(let error):
            completion(.error(error))
        }
    }
    
    public func getObjects(with cachePolicy: CachePolicy, completion: (CacheResult<[CachedObject]>) -> Void) {
        guard let realm = try? realmInstance() else {
            completion(.error(CacheRealmPersistentStoreError.realmUnavailable))
            return
        }
        
        var cachedObjects: [CachedRealm] = []
        
        for type in cacheCompatibleTypes {
            let objects = realm.objects(type)
                .compactMap { $0 as? CachedRealmObject }
                .filter { $0.cachePolicyIdentifier == cachePolicy.identifier }
                .map { $0.toObject() }
            
            cachedObjects.append(contentsOf: objects)
        }
        
        completion(.success(cachedObjects))
    }
    
    public func delete(with cacheInformation: CacheInformation, completion: (CacheResult<Bool>) -> Void) {
        guard let realm = try? realmInstance() else {
            completion(.error(CacheRealmPersistentStoreError.realmUnavailable))
            return
        }
        
        let result = cachedRealmObject(cacheId: cacheInformation.objectCacheId)
        
        switch result {
        case .success(let cachedRealmObject):
            do {
                try realm.write {
                    realm.delete(cachedRealmObject, cascading: true)
                }
                completion(.success(true))
            } catch let error {
                completion(.error(error))
            }
        case .failure(let error):
            completion(.error(error))
        }
    }
        
    public func delete(with cachePolicy: CachePolicy, completion: (CacheResult<Bool>) -> Void) {
        guard let realm = try? realmInstance() else {
            completion(.error(CacheRealmPersistentStoreError.realmUnavailable))
            return
        }
        
        var objectsToDelete: [CachedRealmObject] = []
        
        for type in cacheCompatibleTypes {
            let objects = realm.objects(type)
                .compactMap { $0 as? CachedRealmObject }
                .filter { $0.cachePolicyIdentifier == cachePolicy.identifier }
            
            objectsToDelete.append(contentsOf: objects)
        }
                
        do {
            try realm.write {
                realm.delete(objectsToDelete, cascading: true)
            }
            
            completion(.success(true))
        } catch let error {
            completion(.error(error))
        }
    }
    
    /// Drop object in database to respect size of cache policy
    ///
    /// - Parameter cachePolicies: Specific cache policy
    public func trimToCacheSize(cachePolicies: [CachePolicy]) {
        do {
            var objectsToRemove: [CachedRealmObject] = []
            
            for cachePolicy in cachePolicies {
                var cachePolicyObjects: [CachedRealmObject] = [] // Array will contains all objects in specified cache policy
                
                // For each cache compatible types we retrive realm object
                for objectType in cacheCompatibleTypes {
                    let objects = Array(try realmInstance().objects(objectType)
                        .compactMap({ $0 as? CachedRealmObject }) // map with CacheObject to let us to use cachePolicyIdentifier property
                        .filter({ $0.cachePolicyIdentifier == cachePolicy.identifier }))
                    cachePolicyObjects.append(contentsOf: objects)
                }
                
                // Check if cache is filled and remove some objects if needeed
                if cachePolicyObjects.count > cachePolicy.numberOfElements {
                    let diff = cachePolicyObjects.count - cachePolicy.numberOfElements
                    // Sort array by cache date
                    cachePolicyObjects.sort(by: { $0.cacheDate.timeIntervalSince1970 < $1.cacheDate.timeIntervalSince1970 })
                    // Get surplus objects
                    let cachePolicyObjectsToRemove = cachePolicyObjects[0..<diff]
                    objectsToRemove.append(contentsOf: cachePolicyObjectsToRemove)
                }
            }
            try realmInstance().write {
                try realmInstance().delete(objectsToRemove.compactMap({ $0 as Object }))
            }
        } catch let error {
            SwiftyBeaver.self.error("error when trim cache size : \(error)")
        }
    }
    
    public func dereferenceObject(with cacheInformation: CacheInformation, completion: (CacheResult<Bool>) -> Void) {
        
    }
    
    public func dereferenceObjects(with cachePolicy: CachePolicy, completion: (CacheResult<Bool>) -> Void) {
        
    }
    
    public func deleteAll() {
        do {
            try realmInstance().write {
                try realmInstance().deleteAll()
            }
        } catch let error {
            SwiftyBeaver.self.error("error when delete all cache: \(error)")
        }
    }
}

/// represents a cached Object every objects that we want to cache needs to implements this protocol
public protocol CachedObject {
    /// The property used as an id for the cache
    var cacheId: String { get }
}

/// Result enum that return case .success when the async job is a success and .error when it's an error
///
/// - Success: in this case, you will get back the response from your call if the job is a success
/// - Error:  in this case, you will get back the error from your call if the job encounter an error
public enum CacheResult<T> {
    case success(T)
    case error(Error)
}

/// this object is composed of all the informations needed to find the right object
/// It can be extended to add more informations
public protocol QueryBundle {
    /// The property used as an id to find the right object
    var id: String { get }
    
    /// The property used as cache policy identifier
    var cachePolicyIdentifier: String { get }
}


/// This protocol is composed by a QueryBundle and a local associated Type, that must be a realm Object type
public protocol LocalQueryBundle: QueryBundle {
    var associatedType: AnyObject.Type { get }
}

/// Structure that represents cache information, this struct is "generated" with object id & cache policy
public struct CacheInformation {
    
    /// The property used as an id for the cached object
    public var objectCacheId: String
    
    /// The property used as identifier of the cache policy that we apply to this object
    public var cachePolicyIdentifier: String
    
    // The property creation date of the object
    public var creationDate: Date
    
    // The property last refresh date of the object
    public var lastRefreshDate: Date
    
    /// Cache information intializer
    ///
    /// - Parameters:
    ///   - cacheId: a cache id
    ///   - cachePolicyIdentifier: a cache policy identifier
    public init(cacheId: String, cachePolicyIdentifier: String) {
        self.objectCacheId = cacheId
        self.cachePolicyIdentifier = cachePolicyIdentifier
        self.creationDate = Date()
        self.lastRefreshDate = self.creationDate
    }
}

/// Structure that represents a cache Policy
public struct CachePolicy: Equatable {
    
    /// the expiration time (in s) after what an object expired
    public let expirationTime: Int
    
    /// the refreshing time (in s) after what an object needs to be refresh
    public let refreshingTime:Int
    
    /// the max number of elements that we keep in the cache. We need to trim the cache if we have more than that number of elements
    public let numberOfElements: Int
    
    /// identifier of the cache policy. Needed in order to get back the right cache policy
    public let identifier: String
    
    /// Inits a cache policy
    ///
    /// - Parameters:
    ///   - expirationTime: the expiration time (in s) after what an object expired (default is 24 h)
    ///   - refreshingTime: the refreshing time (in s) after what an object needs to be refresh (default is 24 h)
    ///   - numberOfElements: the max number of elements that we keep in the cache. We need to trim the cache if we have more than that number of elements (default is 100)
    ///   - identifier: identifier of the cache policy. Needed in order to get back the right cache policy
    public init(expirationTime: Int = 1 * 24 * 3600, refreshingTime: Int = 1 * 24 * 3600, numberOfElements: Int = 100, identifier: String) {
        self.expirationTime = expirationTime
        self.refreshingTime = refreshingTime
        self.numberOfElements = numberOfElements
        self.identifier = identifier
    }
}

public func ==(lhs: CachePolicy, rhs: CachePolicy) -> Bool {
    if lhs.identifier == rhs.identifier {
        return true
    }
    
    return false
}

/// Enum to list cache errors.
///
/// - notSupported: Object is not extend CachedRealm protocol.
/// - notCached: Object is not cached in database.
/// - realmUnavailable: Triggered when we didn't succeed to initialize a realm instance
public enum CacheRealmPersistentStoreError: Error {
    case notSupported
    case notCached
    case realmUnavailable
}
