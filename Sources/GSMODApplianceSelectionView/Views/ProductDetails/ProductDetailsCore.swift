//
//  ProductDetailsCore.swift
//
//
//  Created by Samir Tiouajni on 31/05/2024.
//

import GSMODApplianceSelectionComposableInterfaces
import RxComposableArchitecture


import GSMODApplianceSelectionKit




public struct ProductDetailsCore<Cores: ApplianceCoreInterfaces>: TCACore {
    
    public struct State: Equatable {
        
        var productId: ProductId
        var shouldDisplayInformation: Bool
        var domainName: String
        var brandName: String
        var selectedCapacity: String?
        var applianceDomainConfigurations: [RawDomain: ApplianceDomainConfiguration]
        var isUserConnected: Bool
        // To display Pairing Flow
        var displayProductPairing: Bool
        
        var applianceNickname: String
        var selectedAppliance: SelectedAppliance?
        var appliances: [Appliance]
        var applianceInformations: [String]
        var kitchenwareAvailable: Bool
        var selectedKitchenwaresCount: Int
        var isLoading: Bool
        var isNicknameEditing: Bool
        
        var displayPairingCard: Bool {
            guard let selectedAppliance = selectedAppliance,
                    selectedAppliance.connectableType == .iot
            else { return false }
            /// if iotSerialId != nil that mean that the selected appliance is paired
            guard selectedAppliance.iotSerialId != nil
            else { return isUserConnected }
            return false
        }
        
//        var errorAlert: AlertState<Action>?
//        var confirmationDeleteAlert: AlertState<Action>?
        
        @CopyOnWrite var kitchenwareList: KitchenwareListCore<Cores>.State?
        
        // swiftlint:disable:next function_parameter_count
        public static func initial(
            productId: ProductId,
            isUserConnected: Bool,
            shouldDisplayInformation: Bool,
            brandName: String,
            selectedCapacity: String?,
            applianceDomainConfigurations: [RawDomain: ApplianceDomainConfiguration]
        ) -> Self {
            .init(
                productId: productId,
                shouldDisplayInformation: shouldDisplayInformation,
                domainName: "",
                brandName: brandName,
                selectedCapacity: selectedCapacity, 
                applianceDomainConfigurations: applianceDomainConfigurations, 
                isUserConnected: isUserConnected,
                displayProductPairing: false,
                applianceNickname: "",
                appliances: [],
                applianceInformations: [],
                kitchenwareAvailable: false,
                selectedKitchenwaresCount: 0, 
                isLoading: false,
                isNicknameEditing: false
            )
        }
    }
    
    public enum Report: Equatable {
        /// The user wants to see the manual of the appliance with id `applianceId`
        case requestedManual(applianceId: ApplianceId)
        /// The user deleted a product with id `productId`.
        /// `backAction` can be called to pop back to the previous screen
        /// Works even if other presentables have been stacked since
        case deleted(productId: ProductId)
        /// The user chose close product detail
        case closed
    }
    
    public enum Action: Equatable {
        /// For Analytics
        case didAppear
        
        case onResume
        
        case fetchSelectedAppliance
        case updateSelectedAppliance(SelectedAppliance)
        
        case updateCustomInfos(SelectedAppliance, [Kitchenware], [ProductDetailCustomInfo])
        
        /// Actions to adapt ApplianceDeclarationCore to ApplianceHeaderViewState
        case updateNickname(String)
        case saveNickname
        case setNickName(Bool)
        
        case userTappedDelete
        case validateDeletion
        case confirmDelete
        
        case userTappedProductPairing
        case dismissAppliancePairing
        
        case dismissAlert
        
        case userTappedKitchenwares(productId: ProductId)
        case dismissKitchenwareList
        
        case handleError(EquatableError)
        
        case report(Report)
        
        case kitchenwareList(KitchenwareListCore<Cores>.Action)
    }
    
    public struct Environment: TrackedCoreEnvironment {
        
        // MARK: - Services
        let appliancesService: AppliancesService
        let kitchenwaresService: KitchenwaresService
        let selectedAppliancesService: SelectedAppliancesService
        let productDetailUIDatasource: ProductDetailUIDatasource
        
        var kitchenwareList: KitchenwareListCore<Cores>.Environment
        
        public static func live(
            servicesFactory: ApplianceServicesFactory,
            base: Cores.BaseEnvironment,
            productDetailUIDatasource: ProductDetailUIDatasource
        ) -> Self {
            .init(
                appliancesService: servicesFactory.buildAppliancesService(),
                kitchenwaresService: servicesFactory.buildKitchenwaresService(),
                selectedAppliancesService: servicesFactory.buildSelectedAppliancesService(),
                productDetailUIDatasource: productDetailUIDatasource,
                kitchenwareList: .live(
                    base: base,
                    syncType: servicesFactory.configuration.syncType,
                    userProductsService: servicesFactory.userProductsService
                )
            )
        }
        
        public static func mock(
            servicesFactory: ApplianceServicesFactory,
            base: Cores.BaseEnvironment
        ) -> Self {
            .init(
                appliancesService: servicesFactory.buildAppliancesService(),
                kitchenwaresService: servicesFactory.buildKitchenwaresService(),
                selectedAppliancesService: servicesFactory.buildSelectedAppliancesService(),
                productDetailUIDatasource: MockProductDetailUIDatasource(),
                kitchenwareList: .mock(
                    servicesFactory: servicesFactory,
                    base: base
                )
            )
        }
    }
    
    public static var featureReducer: Self.Reducer { .init { state, action, env in
        switch action {
            
        case .didAppear:
            break
            
        case .onResume:
            return .just(.fetchSelectedAppliance)
            
        case .fetchSelectedAppliance:
            return fetchSelectedAppliances(state, env)
            
        case .updateCustomInfos(let selectedAppliance, let kitchenwares, let customInfos):
            state.selectedAppliance = selectedAppliance
            state.selectedKitchenwaresCount = kitchenwares.filter({ $0.isSelectable && selectedAppliance.selectedKitchenware.contains($0.key) }).count
            state.kitchenwareAvailable = kitchenwares.filter { $0.isSelectable }.count > 0
            state.applianceNickname = selectedAppliance.nickname ?? selectedAppliance.appliance.name
            state.domainName = DomainInfo.domainName(
                for: selectedAppliance.rawDomain,
                state.applianceDomainConfigurations
            )
            getApplianceInfos(
                selectedAppliance,
                customInfos,
                applianceInformations: &state.applianceInformations
            )
            
        case .updateNickname(let nickname):
            state.applianceNickname = nickname
            
        case .setNickName(let isEditing):
            state.isNicknameEditing = isEditing
            
        case .saveNickname:
            state.isNicknameEditing = true
            setApplianceNickname(state: &state)
            guard let appliance = state.selectedAppliance else { break }
            return env.selectedAppliancesService
                .updateSelectedAppliance(appliance)
                .catchToResult()
                .splitResultToActionEffect(
                    action: { .updateSelectedAppliance($0) },
                    failureAction: { .handleError($0.equatable) }
                )
            
        case .updateSelectedAppliance(let selectedAppliance):
            state.selectedAppliance = selectedAppliance
            state.isNicknameEditing = false
            
        case .validateDeletion:
            state.isLoading = true
            return env
                .selectedAppliancesService
                .removeSelectedAppliance(productId: state.productId)
                .catchToResult()
                .splitResultToActionEffect(
                    action: { .confirmDelete },
                    failureAction: { .handleError($0.equatable) }
                )
            
        case .confirmDelete:
            state.isLoading = false
            return .just(.report(.deleted(productId: state.productId)))
            
        case .userTappedDelete:
            break
//            state.confirmationDeleteAlert = state.deletionConfirmationAlert
            
        case .userTappedProductPairing:
            state.displayProductPairing = true
            
        case .handleError(let error):
            log.error("ProductDetailsCore fetchSelectedAppliance error: \(error)")
//            state.errorAlert = .defaultError(acknowledge: .dismissAlert)
            
        case .dismissAlert:
            break
//            state.confirmationDeleteAlert = nil
//            state.errorAlert = nil
            
        case .userTappedKitchenwares(let productId):
            state.kitchenwareList = .initial(
                productId: productId,
                disclosureType: .info
            )
            
        case .dismissAppliancePairing:
            state.displayProductPairing = false
            
        case .dismissKitchenwareList:
            state.kitchenwareList = nil
            
        case .kitchenwareList(.report(let report)):
            switch report {
            case .finishedSelection:
                return .just(.dismissKitchenwareList)
            }
            
        case .kitchenwareList:
            break // handled by child
            
        case .report:
            break // handled by parent
        }
        return .none
    }
    .combined(with: analyticsMiddleware)
    .combined(with: kitchenwareListReducer)
    }
    
    private static var kitchenwareListReducer: Self.Reducer { KitchenwareListCore<Cores>.reducer(
        state: \State.kitchenwareList,
        action: /Action.kitchenwareList,
        environment: { $0.kitchenwareList },
        dependencies: .none
    )}
}
