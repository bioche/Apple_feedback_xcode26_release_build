//
//  KitchenwaresRepository.swift
//  GSMODApplianceSelectionKit
//
//  Created by Olivier Tavel on 10/07/2019.
//  Copyright © 2019 groupeseb. All rights reserved.
//

import Foundation




import RxSwift


struct KitchenwaresQueryBundle: QueryBundle {
    
    static func id(locale: GSLocale, applianceGroup: String) -> String {
        ""
//         KitchenwaresNetwork.buildRequest(locale: locale, applianceGroup: applianceGroup)
    }
    
    var id: String {
        ""
//        KitchenwaresNetwork
//            .buildRequest(locale: locale, applianceGroup: applianceGroup)
    }
    let cachePolicyIdentifier = CachePolicy.kitchenwares.identifier
    
    let applianceGroup: String
    let locale: GSLocale
}

struct KitchenwaresRepository: KitchenwaresService {
    let cacheProvider: RemoteCacheProvider
    let locale: GSLocale

    init(network: KitchenwaresNetworkService, persistentStore: CachePersistentStore, locale: GSLocale) {
        self.cacheProvider = RemoteCacheProvider(fetcher: network, persistentStore: persistentStore, policies: [CachePolicy.kitchenwares])
        self.locale = locale
    }
    
    func getKitchenwares(applianceGroup: String) -> Observable<[Kitchenware]> {
        Observable.create { observer in
            let kitchenwaresQueryBundle = KitchenwaresQueryBundle(
                applianceGroup: applianceGroup,
                locale: self.locale
            )
            
            // Request CacheProvider
            self.cacheProvider
                .getObject(with: kitchenwaresQueryBundle, completion: { (result: CacheResult<KitchenwaresList>) in
                    switch result {
                    case .success(let kitchenwaresList):
                        observer.onNext(kitchenwaresList.kitchenwares)
                        observer.onCompleted()
                    case .error:
                        observer.onError(ApplianceError.kitchenwaresNotFound(applianceGroup: applianceGroup))
                    }
                })
            
            return Disposables.create { }
        }
    }
    
    func invalidateCache() {
        cacheProvider.persistentStore.deleteAll()
    }
}
