//
//  KitchenwaresNetworkService.swift
//  GSMODApplianceSelectionKit
//
//  Created by Olivier Tavel on 10/07/2019.
//  Copyright © 2019 groupeseb. All rights reserved.
//

import Foundation




import RxSwift

public protocol KitchenwaresNetworkService: CacheFetcher {
    func getKitchenwares(locale: GSLocale, applianceGroup: String) -> Observable<[Kitchenware]>
    var disposeBag: DisposeBag { get }
}

extension KitchenwaresNetworkService {
    public func getObject(with queryBundle: QueryBundle, completion: @escaping (CacheResult<CachedObject>) -> Void) {
        guard let kitchenwaresQueryBundle = queryBundle as? KitchenwaresQueryBundle else {
            return
        }
        
        let locale = kitchenwaresQueryBundle.locale
        let applianceGroup = kitchenwaresQueryBundle.applianceGroup
        
        getKitchenwares(locale: locale, applianceGroup: applianceGroup)
            .subscribe(onNext: { kitchenwares in
                completion(.success(KitchenwaresList(kitchenwares: kitchenwares, locale: locale, applianceGroup: applianceGroup)))
            }, onError: { error in
                completion(.error(error))
            })
            .disposed(by: disposeBag)
    }
}
