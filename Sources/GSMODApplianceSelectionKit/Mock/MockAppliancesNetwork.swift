//
//  MockAppliancesNetwork.swift
//  GSMODApplianceSelectionKit
//
//  Created by Olivier Tavel on 28/08/2019.
//  Copyright © 2019 groupeseb. All rights reserved.
//

import Foundation

import RxSwift

class MockApplianceNetwork: AppliancesAPIService {
    // MARK: - Rx
    let disposeBag = DisposeBag()
    let simulateFailedRequest: Bool
    
    // MARK: - Initializer
    public init(simulateFailedRequest: Bool = false) {
        self.simulateFailedRequest = simulateFailedRequest
    }
    
    // MARK: - Request
    func getAppliances(locale: GSLocale, syncType: SyncType) -> Observable<ApplianceSyncResponse> {
        let response = ApplianceSyncResponse(appliances: [.cakeFactoryStub(), .companionStub(), .cookeoStub(), .aspirobotStub()], locale: locale, syncType: syncType)
        return  Observable.just(response)
    }
}
