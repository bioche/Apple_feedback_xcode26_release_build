//
//  AppliancesAPIService.swift
//  GSMODApplianceSelectionKit
//
//  Created by Olivier Tavel on 25/06/2019.
//  Copyright © 2019 groupeseb. All rights reserved.
//

import Foundation




import RxSwift

protocol AppliancesAPIService: CacheFetcher {
    /// Get all appliances from DCP
    ///
    /// - Returns: Observable of array of ApplianceSyncResponse
    func getAppliances(locale: GSLocale, syncType: SyncType) -> Observable<ApplianceSyncResponse>
    
    // Needed to factorize the cache method
    var disposeBag: DisposeBag { get }
}

extension AppliancesAPIService {
    func getObject(with queryBundle: QueryBundle, completion: @escaping (CacheResult<CachedObject>) -> Void) {
        guard let applianceQueryBundle = queryBundle as? AppliancesQueryBundle else {
            assertionFailure("Wrong query bundle : \(queryBundle). Expected AppliancesQueryBundle")
            completion(.error(ApplianceError.appliancesNotFound))
            return
        }
        
        getAppliances(locale: applianceQueryBundle.locale, syncType: applianceQueryBundle.syncType)
            .subscribe(onNext: { response in
                completion(.success(response))
            }, onError: { _ in
                completion(.error(ApplianceError.appliancesNotFound))
            })
            .disposed(by: disposeBag)
    }
}

/// Representation of a Cache Fetcher, a fetcher needs to implement this protocol
public protocol CacheFetcher {
    /// let us get an object from the fetcher
    ///
    /// - Parameters:
    ///   - queryBundle: the query that will help us track the right object
    ///   - completion: return the CacheResult type when the async job is complete
    func getObject(with queryBundle: QueryBundle, completion: @escaping (CacheResult<CachedObject>) -> Void)
}
