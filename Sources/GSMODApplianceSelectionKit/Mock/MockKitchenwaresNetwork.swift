//
//  MockKitchenwaresNetwork.swift
//  GSMODApplianceSelectionKit
//
//  Created by Olivier Tavel on 28/08/2019.
//  Copyright © 2019 groupeseb. All rights reserved.
//

import Foundation





import RxSwift

public class MockKitchenwaresNetwork: KitchenwaresNetworkService {

    // MARK: - Rx
    public let disposeBag = DisposeBag()
    
    public var kitchenwaresResult: Result<[Kitchenware], Error>
    
    // MARK: - Initializer
    public init(kitchenwaresResult: Result<[Kitchenware], Error>) {
        self.kitchenwaresResult = kitchenwaresResult
    }
    
    // MARK: - Request
    public func getKitchenwares(locale: GSLocale, applianceGroup: String) -> Observable<[Kitchenware]> {
        switch kitchenwaresResult {
        case .success(let kitchenwares):
            return .just(kitchenwares)
        case .failure(let failure):
            return .error(failure)
        }
    }
}
