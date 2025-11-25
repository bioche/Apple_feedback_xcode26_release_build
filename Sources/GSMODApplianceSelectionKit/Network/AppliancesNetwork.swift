//
//  AppliancesNetwork.swift
//  GSMODApplianceSelectionKit
//
//  Created by Olivier Tavel on 25/06/2019.
//  Copyright © 2019 groupeseb. All rights reserved.
//

import Foundation





import RxSwift

//class AppliancesNetwork: AppliancesAPIService, DCPNetworking {
//    // MARK: - Endpoint
//    static let appliancesUrlPath = "common-api/v2/sync/appliances/0/"
//    
//    // MARK: - Properties
//    let dcpClient: DCPWebClient
//
//    /// TODO: Temporary fix to avoid multiple request at same time
//    private static var appliancesRequestsObservable: [String: Observable<ApplianceSyncResponse>] = [:]
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
//    func getAppliances(locale: GSLocale, syncType: SyncType) -> Observable<ApplianceSyncResponse> {
//        let urlPath = Self.buildRequest(locale: locale, syncType: syncType)
//        
//        guard let inProgressRequest = Self.appliancesRequestsObservable[urlPath] else {
//            let getAppliancesRequest: Observable<ApplianceSyncResponse> =
//                request(.get, urlPath: urlPath)
//                    .map { (raw: RawApplianceSyncResponse) in
//                        ApplianceSyncResponse(appliances: raw.appliances, locale: locale, syncType: syncType)
//                    }
//                    .share(replay: 1)
//                    .do(onCompleted: {
//                        Self.appliancesRequestsObservable.removeValue(forKey: urlPath)
//                    })
//            
//            Self.appliancesRequestsObservable[urlPath] = getAppliancesRequest
//            
//            return getAppliancesRequest
//        }
//                
//        return inProgressRequest
//    }
//    
//    static func buildRequest(locale: GSLocale, syncType: SyncType) -> String {
//        var urlPath = AppliancesNetwork.appliancesUrlPath + "?lang=\(locale.market.language)&market=\(locale.market.name)"
//        urlPath.append("&status=\(syncType.dcpFormatted)")
//        return urlPath
//    }
//}

/// The possible type of the sync for dcp
///
/// - draftOnly: synchronizes only appliances in draft mode in the BO
/// - publishedOnly: synchronizes only appliances in published mode in the BO
/// - all: synchronizes draft and published appliances
public enum SyncType {
    case draftOnly
    case publishedOnly
    case all
    
    var dcpFormatted: String {
        switch self {
        case .draftOnly:
            return "DRAFT"
        case .publishedOnly:
            return "PUBLISHED"
        case .all:
            return "DRAFT,PUBLISHED"
        }
    }
}
