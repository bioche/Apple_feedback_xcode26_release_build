//
//  SampleCore.swift
//  GSMODApplianceSelectionExample
//
//  Created by Samir Tiouajni on 05/06/2024.
//  Copyright © 2024 groupeseb. All rights reserved.
//

import GSMODApplianceSelectionComposableInterfaces
import RxComposableArchitecture


import GSMODApplianceSelectionView
import GSMODApplianceSelectionKit

import GSMODWebClient
import GSMODCore

enum ApplianceRoute: String, Equatable, CaseIterable {
    case firstSelection = "First Selection"
    case productDetail = "My Product Details"
    case kitchenwareList = "Kitchenware List"
    case resetDatabase = "Reset database"
}

struct SampleCore: TCACore {
    struct State: Equatable {
        
        let datas: [ApplianceRoute]
        let applianceDomainConfigurations: [RawDomain: ApplianceDomainConfiguration]
        
        var errorAlert: AlertState<Action>?
        @CopyOnWrite var firstSelection: ApplianceFirstSelectionCore<ApplianceCoreMock>.State?
        @CopyOnWrite var productDetail: ProductDetailsCore<ApplianceCoreMock>.State?
        @CopyOnWrite var kitchenwareList: KitchenwareListCore<ApplianceCoreMock>.State?
        
        static func initial(
            applianceDomainConfigurations: [RawDomain: ApplianceDomainConfiguration]
        ) -> Self {
            .init(
                datas: ApplianceRoute.allCases, 
                applianceDomainConfigurations: applianceDomainConfigurations
            )
        }
    }
    
    enum Action: Equatable {
        case userTappedFirstSelection(ApplianceRoute)
        
        case dismissFirstSelection
        case dismissProductDetail
        case dismissKitchenwareList
        
        case dismissAlert
        
        case firstSelection(ApplianceFirstSelectionCore<ApplianceCoreMock>.Action)
        case productDetail(ProductDetailsCore<ApplianceCoreMock>.Action)
        case kitchenwareList(KitchenwareListCore<ApplianceCoreMock>.Action)
    }
    
    struct Environment {
        
        var firstSelection: ApplianceFirstSelectionCore<ApplianceCoreMock>.Environment
        var productDetail: ProductDetailsCore<ApplianceCoreMock>.Environment
        var kitchenwareList: KitchenwareListCore<ApplianceCoreMock>.Environment
        
        static func live() -> Self {
            
            let base = ApplianceCoreMock.BaseEnvironment(
                webclient: DCPWebClient(),
                locale: .init(
                    market: .init(
                        language: "fr",
                        country: "FR",
                        name: "GS_FR"
                    )
                )
            )
            
            let servicesFactory = ApplianceDefaultServicesFactory(
                configuration: .mock(
                    market: base.locale.marketName,
                    country: base.locale.market.country,
                    language: base.locale.language
                ),
                userProductsService: UserProductsGateway(),
                fetchSAVUrlPath: { .just("https://www.apple.com") },
                autoDetectionService: MockAutoDetectionService()
            )
            
            return .init(
                firstSelection: .live(
                    servicesFactory: servicesFactory,
                    base: base,
                    productDetailUIDatasource: SampleProductDetailUIDatasource()
                ), 
                productDetail: .live(
                    servicesFactory: ApplianceDefaultServicesFactory(
                        configuration: servicesFactory.configuration,
                        userProductsService: UserProductsGateway(),
                        fetchSAVUrlPath: { .just("https://www.apple.com") },
                        autoDetectionService: MockAutoDetectionService()
                    ),
                    base: base,
                    productDetailUIDatasource: SampleProductDetailUIDatasource()
                ), 
                kitchenwareList: .live(
                    base: base,
                    syncType: servicesFactory.configuration.syncType,
                    userProductsService: UserProductsGateway()
                )
            )
        }
    }
    
    static let featureReducer: Reducer = Reducer { state, action, _ in
        switch action {
        case .userTappedFirstSelection(let applianceRoute):
            switch applianceRoute {
            case .firstSelection:
                state.firstSelection = .initial(
                    applianceEditableLaterLabelHidden: false,
                    allowMultipleAppliancesPerDomain: true,
                    shouldDisplayInformation: true,
                    isBackButtonDisplayed: false
                )
                return .just(.firstSelection(.applyReload))
            case .productDetail:
                guard let product = UserProductsGateway.userProducts.first else {
                    log.info("Can't find product")
                    state.errorAlert = state.alert(
                        title: "Error",
                        message: "Merci de sélectionner un produit"
                    )
                    break
                }
                state.productDetail = .initial(
                    productId: product.productId, 
                    isUserConnected: true,
                    shouldDisplayInformation: true,
                    brandName: "Cookeat",
                    selectedCapacity: product.selectedCapacity?.description, 
                    applianceDomainConfigurations: state.applianceDomainConfigurations
                )
            case .kitchenwareList:
                guard let productId = UserProductsGateway.userProducts.first?.productId else {
                    log.info("Can't find product")
                    state.errorAlert = state.alert(
                        title: "Error",
                        message: "Merci de sélectionner un produit"
                    )
                    break
                }
                state.kitchenwareList = .initial(
                    productId: productId,
                    disclosureType: .info
                )
            case .resetDatabase:
                if let error = deleteDocumentsDirectoryContents() {
                    state.errorAlert = state.alert(
                        title: "error",
                        message: error.localizedDescription
                    )
                } else {
                    state.errorAlert = state.alert(
                        title: "Success",
                        message: "Databases deleted"
                    )
                }
            }
            
        case .dismissFirstSelection:
            state.firstSelection = nil
            
        case .dismissProductDetail:
            state.productDetail = nil
            
        case .dismissKitchenwareList:
            state.kitchenwareList = nil
            
        case .dismissAlert:
            state.errorAlert = nil
            
        case .firstSelection(.report(let report)):
            switch report {
            case .validated:
                return .just(.dismissFirstSelection)
            case .deniedCreation(selectedAppliance: let selectedAppliance):
                return .none
            }
            
        case .productDetail(.report(let report)):
            switch report {
            case .deleted(let applianceId):
                return .just(.dismissProductDetail)
            case .requestedManual(let applianceId):
                return .just(.dismissProductDetail)
            case .closed:
                return .just(.dismissProductDetail)
            }
            
        case .kitchenwareList(.report(let report)):
            switch report {
            case .finishedSelection:
                return .just(.dismissKitchenwareList)
            }
            
        case .firstSelection, .productDetail, .kitchenwareList:
            break // handled by child
        }
        return .none
    }
    .combined(with: firstSelectionReducer)
    .combined(with: productDetailReducer)
    .combined(with: kitchenwareListReducer)
    
    static let firstSelectionReducer: Self.Reducer = ApplianceFirstSelectionCore<ApplianceCoreMock>.reducer(
        state: \.firstSelection,
        action: /Action.firstSelection,
        environment: { $0.firstSelection },
        dependencies: .none
    )
    
    static let productDetailReducer: Self.Reducer = ProductDetailsCore<ApplianceCoreMock>.reducer(
        state: \.productDetail,
        action: /Action.productDetail,
        environment: { $0.productDetail },
        dependencies: .none
    )
    
    static let kitchenwareListReducer: Self.Reducer = KitchenwareListCore<ApplianceCoreMock>.reducer(
        state: \.kitchenwareList,
        action: /Action.kitchenwareList,
        environment: { $0.kitchenwareList },
        dependencies: .none
    )
}

extension SampleCore.State {
    
    func alert(
        title: String,
        message: String
    ) -> AlertState<SampleCore.Action> {
        .init(
            title: title,
            message: message,
            dismissButton: .cancel("OK", send: .dismissAlert)
        )
    }
}
