//
//  KitchenwaresNetwork.swift
//  GSMODApplianceSelectionKit
//
//  Created by Olivier Tavel on 10/07/2019.
//  Copyright © 2019 groupeseb. All rights reserved.
//

import Foundation





import RxSwift

//class KitchenwaresNetwork: KitchenwaresNetworkService, DCPNetworking {
//    // MARK: - Endpoint
//    static let kitchenwaresUrlPath = "/common-api/v2/kitchenwares"
//    
//    // MARK: - Properties
//    let dcpClient: DCPWebClient
//
//    // TODO: Temporary fix to avoid multiple request at same time
//    private static var kitchenwareRequestsObservable: [String: Observable<[Kitchenware]>] = [:]
//    
//    // MARK: - Rx
//    let disposeBag = DisposeBag()
//
//    // MARK: - Initializer
//    init(dcpClient: DCPWebClient) {
//        self.dcpClient = dcpClient
//    }
//    
//    // MARK: - Request
//    func getKitchenwares(locale: GSLocale, applianceGroup: String) -> Observable<[Kitchenware]> {
//        let urlPath = Self.buildRequest(locale: locale, applianceGroup: applianceGroup)
//    
//        guard let inProgressRequest = Self.kitchenwareRequestsObservable[urlPath] else {
//            let getKitchenwaresRequest: Observable<[Kitchenware]> = request(.get, urlPath: urlPath)
//                .share(replay: 1)
//                .do(onCompleted: {
//                    Self.kitchenwareRequestsObservable.removeValue(forKey: urlPath)
//                })
//            
//            Self.kitchenwareRequestsObservable[urlPath] = getKitchenwaresRequest
//            
//            return getKitchenwaresRequest
//        }
//                
//        return inProgressRequest
//    }
//    
//    static func buildRequest(locale: GSLocale, applianceGroup: String) -> String {
//        var urlPath = KitchenwaresNetwork.kitchenwaresUrlPath + "?language=\(locale.market.language)&market=\(locale.market.name)"
//        urlPath.append("&applianceGroup=\(applianceGroup)")
//        return urlPath
//    }
//}
