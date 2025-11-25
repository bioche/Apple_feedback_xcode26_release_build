//
//  AppliancesRepository.swift
//  GSMODApplianceSelectionKit
//
//  Created by Olivier Tavel on 09/07/2019.
//  Copyright © 2019 groupeseb. All rights reserved.
//

import Foundation




import RxSwift
import RxRelay

struct AppliancesQueryBundle: QueryBundle {
//    // We only keep one appliance list at a time. --> One single Id
//    // When locale changes, cache is cleared
//    static let Id = AppliancesNetwork.appliancesUrlPath
    
    static func id(locale: GSLocale, syncType: SyncType) -> String {
//         AppliancesNetwork.buildRequest(locale: locale, syncType: syncType)
        ""
    }
    
    var id: String { Self.id(locale: locale, syncType: syncType) }
    var cachePolicyIdentifier: String { CachePolicy.appliances.identifier }
    
    let locale: GSLocale
    let syncType: SyncType
}

struct AppliancesRepository: AppliancesService {
    let cacheProvider: RemoteCacheProvider
    
    let locale: GSLocale
    let syncType: SyncType
    
    init(
        network: AppliancesAPIService,
        persistentStore: CachePersistentStore,
        locale: GSLocale,
        syncType: SyncType
    ) {
        self.syncType = syncType
        self.locale = locale
        self.cacheProvider = RemoteCacheProvider(fetcher: network, persistentStore: persistentStore, policies: [CachePolicy.appliances])
    }
    
    func getAppliances() -> Observable<[Appliance]> {
        Observable.create { observer in
            let appliancesQueryBundle = AppliancesQueryBundle(locale: self.locale, syncType: self.syncType)
            
            // Request CacheProvider
            self.cacheProvider
                .getObject(with: appliancesQueryBundle, completion: { (result: CacheResult<ApplianceSyncResponse>) in
                    switch result {
                    case .success(let applianceSyncResponse):
                        observer.onNext(applianceSyncResponse.appliances)
                        observer.onCompleted()
                    case .error(let error):
                        observer.onError(error)
                    }
                })
            return Disposables.create { }
        }
    }
    
    func getAppliances(for domain: RawDomain) -> Observable<[Appliance]> {
        return getAppliances()
            .map({ appliances in
                appliances.filter { $0.rawDomain == domain }
            })
    }
    
    func getAppliance(for applianceId: ApplianceId) -> Observable<Appliance> {
        return getAppliances()
            .map({ appliances in
                guard let appliance = appliances.first(where: { $0.applianceId == applianceId }) else {
                    throw ApplianceError.applianceNotFound(applianceId: applianceId)
                }
                
                return appliance
            })
    }
    
    func invalidateCache() {
        cacheProvider.persistentStore.deleteAll()
    }
}

/// the cache provider is the class that will serve as a facade accessing to our object, it's composed of a fetcher (that will fetch data online) and a persistentStore (that will fetch data on the chosen local persistent layer)
public class RemoteCacheProvider: CacheProvider {
    
    /// The property fetcher, that will fetch data online
    fileprivate let fetcher: CacheFetcher
    
    /// The property persistent store, that will fetch data on the chosen local persistent layer
    public var persistentStore: CachePersistentStore
    
    public var cachePolicies: [String: CachePolicy] = [:]
    
    /// cache provider initializer
    ///
    /// - Parameters:
    ///   - fetcher: a fetcher instance
    ///   - persiStore: a persistentStore instance
    ///   - cachePolicies: a list of cache policies that will be used throughout the life of the cache manager
    public init(fetcher: CacheFetcher, persistentStore: CachePersistentStore, policies: [CachePolicy] = []) {
        self.fetcher = fetcher
        self.persistentStore = persistentStore
        
        policies.forEach { self.cachePolicies[$0.identifier] = $0 }
    }
    
    public func invalidateCache(policy: CachePolicy, completion: @escaping (CacheResult<Bool>) -> Void) {
        persistentStore.dereferenceObjects(with: policy, completion: completion)
    }
    
    public func invalidateCache(information: CacheInformation, completion: @escaping (CacheResult<Bool>) -> Void) {
        persistentStore.dereferenceObject(with: information, completion: completion)
    }
    
    public func getObject<T: CachedObject>(with queryBundle: QueryBundle, completion: @escaping (CacheResult<T>) -> Void) {
        var objectCachingState: ObjectCachingState = .notCached
        
        // First, get cache info with cache policy idenfifier
        persistentStore.getCacheInformation(with: queryBundle) { (cacheInformationResult) in
            switch cacheInformationResult {
            case .success(let cacheInformation):
                // Cache information is stored in cache. Try to get object in local database
                persistentStore.getObject(with: cacheInformation, completion: { (cachedObjectResult) in
                    switch cachedObjectResult {
                    case .success(let cachedObject):
                        // Object is stored in cache we want to retrieve the caching state
                        objectCachingState = getCachingstate(with: cachedObject, cacheinformation: cacheInformation)
                    case .error:
                        // Object not stored in cache.
                        objectCachingState = .notCached
                    }
                })
            case .error:
                // Cache information is not stored in cache.
                objectCachingState = .notCached
            }
            
            // Finally, handle the caching state to do the right Action
            handle(cachingState: objectCachingState, with: queryBundle, completion: { (cachedObjectResult) in
                switch cachedObjectResult {
                case .success(let cachedObject):
                    // Try to cast to generic
                    if let castedCachedObject = cachedObject as? T {
                        completion(.success(castedCachedObject))
                    } else {
                        completion(.error(CacheProviderError.couldntCastObjectAsWantedType(T.self)))
                    }
                case .error(let error):
                    completion(.error(error))
                }
            })
        }
    }
    
    public func handle(cachingState: ObjectCachingState, with queryBundle: QueryBundle, completion: @escaping (CacheResult<CachedObject>) -> Void) {
        switch cachingState {
        case .notCached, .expired:
            // Get new data from server and return it
            fetcher.getObject(with: queryBundle) { [weak self] (fetcherResult) in
                guard let weakSelf = self else { return }
                
                switch fetcherResult {
                case .success(let object):
                    // Create cache information object with object & query information
                    let cacheInformation = CacheInformation(cacheId: object.cacheId, cachePolicyIdentifier: queryBundle.cachePolicyIdentifier)
                    
                    // Save object & cache information in persistent store
                    weakSelf.persistentStore.save(object, with: cacheInformation, completion: { (saveResult) in
                        switch saveResult{
                        case .error(let error):
                            // Return the save error
                            completion(.error(error))
                        case .success:
                            // Object have been retrived from fetcher, we can propagate it
                            completion(.success(object))
                        }
                    })
                    
                    // Trim the cache to the right size
                    weakSelf.persistentStore.trimToCacheSize(cachePolicies: weakSelf.cachePolicies.map { $0.value })
                case .error(let error):
                    // Server request failed, return error
                    completion(.error(error))
                }
            }
            
        case .toRefresh(let affectedObject):
            // get new data and return cached one
            fetcher.getObject(with: queryBundle) { [weak self] (fetcherResult) in
                guard let weakSelf = self else { return }
                
                switch fetcherResult {
                case .success(let object):
                    let cacheInformation = CacheInformation(cacheId: object.cacheId, cachePolicyIdentifier: queryBundle.cachePolicyIdentifier)
                    
                    // Replace the object in persistent store we ignore the save Result in that case because next time we ask for this element, we will go and catch it again
                    weakSelf.persistentStore.save(object, with: cacheInformation, completion: nil)
                    
                    // Trim the cache to the right size
                    weakSelf.persistentStore.trimToCacheSize(cachePolicies: weakSelf.cachePolicies.map { $0.value })
                case .error:
                    // In this case we don't want to propagate errors, the cached object is still valid we just could'nt get an update of it
                    break
                }
            }
            
            // Here we return the affectedObject and not the new fetched one
            completion(.success(affectedObject))
            
        case .valid(let affectedObject):
            // Here we return the affectedObject and not the new fetched one
            completion(.success(affectedObject))
        case .arrayValid(_):
            fatalError("Not impletement yet")
        }
    }
    
    /// Return the caching State of the object
    ///
    /// - Parameter object: the cachedObject To analyze
    /// - Returns: the caching state of the object
    internal func getCachingstate(with cachedObject: CachedObject, cacheinformation: CacheInformation) -> ObjectCachingState {
        guard let cachePolicy = self.getCachePolicy(for: cacheinformation.cachePolicyIdentifier) else {
            return .notCached
        }
        
        // If now equals or is greater than the expiration date, we need to force refresh the data
        // Else If now equals or is greater than the refreshing date,  we need to refresh the data in the background
        // Else it means the data is valid
        let now = Date()
        let expirationDate = cacheinformation.lastRefreshDate.addingTimeInterval(TimeInterval(cachePolicy.expirationTime))
        let refreshingDate = cacheinformation.lastRefreshDate.addingTimeInterval(TimeInterval(cachePolicy.refreshingTime))
        
        if now >= expirationDate {
            return .expired(cachedObject)
        } else if now >= refreshingDate {
            return .toRefresh(cachedObject)
        } else {
            return .valid(cachedObject)
        }
    }
}

protocol CacheProvider {
    //MARK: Cache properties
    /// The property cache policies
    var cachePolicies: [String: CachePolicy] { get set }
    
    /// The property persistent store, that will fetch data on the chosen local persistent layer
    var persistentStore: CachePersistentStore { get set }
    
    //MARK: Cache methods
    /// Invalidates cache of objects with the specified cache policy by removing their cache informations
    ///
    /// - Parameters:
    ///   - policy: The policy of the objects to dereference
    ///   - completion: return a Result type when the async job is complete
    func invalidateCache(policy: CachePolicy, completion: @escaping (CacheResult<Bool>) -> Void)
    
    /// Invalidates cache of an object with the specified cache information
    ///
    /// - Parameters:
    ///   - information: The cache information of the object to dereference
    ///   - completion: return a Result type when the async job is complete
    func invalidateCache(information: CacheInformation, completion: @escaping (CacheResult<Bool>) -> Void)
    
    /// let us get an object by giving an object (InfoBundle) describing the object that we want to get
    ///
    /// - Parameters:
    ///   - info: the description of the object that we want
    ///   - completion: return a Result type when the async job is complete
    func getObject<T: CachedObject>(with queryBundle: QueryBundle, completion: @escaping (CacheResult<T>) -> Void)
    
    /// This method handle the caching State with the object and call the right logic for the right State :
    /// * Fetch and return a new object if .notCached or .expired
    /// * Fetch a new version while returning the actual object in cache if .toRefresh
    /// * return the actual object in cache if .valid
    ///
    /// - Parameters:
    ///   - cachingState: the caching State of the object that was asked
    ///   - info: The Info Bundle that was given when asking for a cache object
    ///   - completion: completion block of the function
    func handle(cachingState: ObjectCachingState, with queryBundle: QueryBundle, completion: @escaping (CacheResult<CachedObject>) -> Void)
    
    //MARK: Cache policy
    /// let us get back a cache policy by gicing its identifier
    ///
    /// - Parameter identifier: the identifier of the cache policy that we want to get
    /// - Returns: the asked cache policy
    func getCachePolicy(for identifier: String ) -> CachePolicy?
    
    /// Let us add a cache policy to the cache provider
    ///
    /// - Parameter cachePolicy: cache policy téo add
    mutating func add(cachePolicy: CachePolicy)
    
    /// let us change the cache policy of a cached object
    ///
    /// - Parameter objectInfo: the object Info element that will let us find the right cached object (the cache policyIdentifier will here let be use to define the new cache policy wanted)
    func set(cachePolicy: String, for object: CachedObject, completion: @escaping(CacheResult<CachedObject>) -> Void)
    
    /// let us delete a cache policy from the cache provider
    ///
    /// - Parameter identifier: the identifier of the cache policy to delete
    mutating func delete(cachePolicy forIdentifier: String)
}


// MARK: - Cache Policy methods
extension CacheProvider {
    
    mutating func add(cachePolicy: CachePolicy) {
        cachePolicies[cachePolicy.identifier] = cachePolicy
    }
    
    func getCachePolicy(for identifier: String ) -> CachePolicy? {
        if let cachePolicy = cachePolicies[identifier] {
            return cachePolicy
        } else {
            return nil
        }
    }
    
    func set(cachePolicy: String, for object: CachedObject, completion: @escaping(CacheResult<CachedObject>) -> Void) {
        // Create Cache info
        let cacheInformation = CacheInformation(cacheId: object.cacheId, cachePolicyIdentifier: cachePolicy)
        
        persistentStore.save(object, with: cacheInformation) { (cachedObjectResult) in
            switch cachedObjectResult {
            case .success(let cachedObject):
                completion(.success(cachedObject))
            case .error (let error):
                completion(.error(error))
            }
        }
    }
    
    mutating func delete(cachePolicy forIdentifier: String) {
        cachePolicies.removeValue(forKey: forIdentifier)
    }
}

/// Enum That gives us the caching state of the current cached object
///
/// - expired: the cached object has expired
/// - toRefresh: the cached object needs to be refreshed
/// - valid: the cached object is valid
/// - notCached: the object isn't cached
public enum ObjectCachingState {
    case expired(CachedObject)
    case toRefresh(CachedObject)
    case valid(CachedObject)
    case arrayValid([CachedObject])
    case notCached
}

enum CacheProviderError<T>: LocalizedError {
    case couldntCastObjectAsWantedType(T.Type)
    
    var errorDescription: String {
        switch self {
        case .couldntCastObjectAsWantedType(let type):
            return "\(self.errorCode) - An error occured, couldn't cast the cachedObject as wanted type : \(type)"
        }
    }
    
    var errorCode: String {
        switch self {
        case .couldntCastObjectAsWantedType(let type):
            return "CacheProvider Couldn't cast the cached Object as asked Type : \(type)"
        }
    }
}
