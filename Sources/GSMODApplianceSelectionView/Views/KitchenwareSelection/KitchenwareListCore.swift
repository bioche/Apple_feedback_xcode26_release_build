//
//  KitchenwareListCore.swift
//  
//
//  Created by Thibault POUJAT on 25/05/2022.
//

import GSMODApplianceSelectionComposableInterfaces

import RxComposableArchitecture

import RxSwift


import GSMODApplianceSelectionKit
import SwiftyBeaver

import Foundation

public struct KitchenwareListCore<Cores: ApplianceCoreInterfaces>: TCACore {
    
    public enum ProductState: Equatable {
        case existing(ProductId, SelectedAppliance?)
        case pending(Appliance)
    }
    
    public enum Error: Swift.Error, Equatable {
        case fetchingSelectedAppliance(EquatableError)
        case validatingSelection(EquatableError)
    }
    
    public struct State: Equatable {
        var productState: ProductState
        
        let disclosureType: DisclosureType
        var kitchenwareCellModelList: [KitchenwareCellModel] = []
        var pendingSelectedKitchenwares: [KitchenwareId] = []
        var isLoading: Bool = false
        
        var errorAlert: RxComposableArchitecture.AlertState<Action>?
        
        var alreadySelectedKitchenwares: [KitchenwareId] {
            switch productState {
            case .existing(_, let selectedAppliance):
                return selectedAppliance?.selectedKitchenware ?? []
            case .pending:
                return pendingSelectedKitchenwares
            }
        }
        
        var selectedKitchenwares: [KitchenwareCellModel] {
            kitchenwareCellModelList.filter { $0.isSelected }
        }
        
        var selectionPossible: Bool {
            disclosureType != .arrow
        }
        
        @CopyOnWrite var kitchenwareDetail: Cores.KitchenwareDetailCore.State?
        
        /// To select kitchenwares while in product detail
        public static func initial(productId: ProductId, disclosureType: DisclosureType) -> Self {
            .init(
                productState: .existing(productId, nil),
                disclosureType: disclosureType
            )
        }
        
        /// To select kitchenwares while in appliance selection
        public static func initial(
            appliance: Appliance,
            selectedKitchenwares: [Kitchenware]
        ) -> Self {
            .init(
                productState: .pending(appliance),
                disclosureType: .none,
                pendingSelectedKitchenwares: selectedKitchenwares.map { $0.key }
            )
        }
    }
    
    public enum Report: Equatable {
        case finishedSelection([Kitchenware])
    }
    
    public enum Action: Equatable {
        case didAppear
        case refreshed(ProductState, [Kitchenware])
        
        case didTapCell(KitchenwareCellModel)
        case didTapDisclosureButton(KitchenwareCellModel)
        
        case didTapDeclareButton
        case validatedSelection([KitchenwareCellModel])
        
        case recoverFromFailure(Error)
        case acknowledgeError
        
        case dismissKitchenwareDetail
        
        case kitchenwareDetail(Cores.KitchenwareDetailCore.Action)
        
        case report(Report)
    }
    
    public struct Environment: TrackedCoreEnvironment {
        
        let baseEnvironment: Cores.BaseEnvironment
        let kitchenwareDetail: Cores.KitchenwareDetailCore.Environment
        
        let kitchenwaresService: KitchenwaresService
        let selectedAppliancesService: SelectedAppliancesService
        var navigationHandler: ((Report) -> Void)?
        
        public static func live(
            base: Cores.BaseEnvironment,
            syncType: SyncType,
            userProductsService: UserProductsService,
            navigationHandler: ((Report) -> Void)? = nil
        ) -> Self {
            .init(
                baseEnvironment: base,
                kitchenwareDetail: .live(base: base),
                kitchenwaresService: liveKitchenwaresService(
                    locale: base.locale
                ),
                selectedAppliancesService: liveSelectedApplianceService(
                    locale: base.locale,
                    syncType: syncType,
                    userProductsService: userProductsService
                ),
                navigationHandler: navigationHandler
            )
        }
        
        public static func mock(
            servicesFactory: ApplianceServicesFactory,
            base: Cores.KitchenwareDetailCore.Environment.BaseEnvironment
        ) -> Self {
            .init(
                baseEnvironment: base,
                kitchenwareDetail: .mock(
                    servicesFactory: servicesFactory,
                    base: base
                ),
                kitchenwaresService: servicesFactory.buildKitchenwaresService(),
                selectedAppliancesService: servicesFactory.buildSelectedAppliancesService()
            )
        }
    }
    
    static func refreshScreen(
        _ productState: ProductState,
        _ env: Environment
    ) -> RxComposableArchitecture.Effect<Action, Never> {
        let observable: Observable<(ProductState, [Kitchenware])> = {
            switch productState {
            case .existing(let productId, _):
                return env.selectedAppliancesService
                    .getSelectedAppliance(productId: productId)
                    .retrieveKitchenwares(kitchenwaresService: env.kitchenwaresService)
                    .map { (ProductState.existing(productId, $0), $1) }
            case .pending(let appliance):
                return env.kitchenwaresService
                    .getKitchenwares(applianceGroup: appliance.groupId)
                    .map { (productState, $0) }
            }
        }()
        return observable
            .catchToResult()
            .asSingle()
            .splitResultToActionEffect(
                action: { .refreshed($0.0, $0.1) },
                failureAction: { .recoverFromFailure(.fetchingSelectedAppliance($0.equatable)) }
            )
    }
    
    static func validate(
        selected: [KitchenwareCellModel],
        _ productState: ProductState,
        _ env: Environment
    ) -> Effect<Action, Never> {
        switch productState {
        case .existing(_, nil):
            assertionFailure("No selected appliance, we should have left the screen earlier")
            return .none
        case .existing(_, var selectedAppliance?):
            selectedAppliance.selectedKitchenware = selected.map { $0.key }
            return env.selectedAppliancesService
                .updateSelectedAppliance(selectedAppliance)
                .catchToResult()
                .asSingle()
                .splitResultToActionEffect(
                    action: { _ in .validatedSelection(selected) },
                    failureAction: { .recoverFromFailure(.validatingSelection($0.equatable)) }
                )
        case .pending:
            return .just(.validatedSelection(selected))
        }
    }
    
    public static var featureReducer: Self.Reducer { .init { state, action, env in
        switch action {
        case .didAppear:
            state.isLoading = true
            return refreshScreen(state.productState, env)
            
        case .refreshed(let productState, let kitchenwareList):
            state.isLoading = false
            state.productState = productState
            state.kitchenwareCellModelList = splitKitchenwares(
                kitchenwareList,
                disclosureType: state.disclosureType,
                selectionPossible: state.selectionPossible,
                alreadySelectedKitchenwares: state.alreadySelectedKitchenwares
            )
            
        case .didTapDisclosureButton(let cellModel):
            state.kitchenwareDetail = .initial(
                kitchenwareDetailConfiguration: .init(
                    kitchenwareId: cellModel.kitchenware.key,
                    kitchenwareName: cellModel.kitchenware.translatedName,
                    kitchenwareShopURL: cellModel.kitchenware.localizedUrls?.first?.redirectionUrl.flatMap { URL(string: $0) },
                    media: cellModel.kitchenware.medias?.first?.media
                )
            )
            
        case .didTapCell(let cellModel):
            if state.selectionPossible {

            } else {
                state.kitchenwareDetail = .initial(
                    kitchenwareDetailConfiguration: .init(
                        kitchenwareId: cellModel.kitchenware.key,
                        kitchenwareName: cellModel.kitchenware.translatedName,
                        kitchenwareShopURL: cellModel.kitchenware.localizedUrls?.first?.redirectionUrl.flatMap { URL(string: $0) },
                        media: cellModel.kitchenware.medias?.first?.media
                    )
                )
            }
            
        case .didTapDeclareButton:
            state.isLoading = true
            return validate(selected: state.selectedKitchenwares, state.productState, env)
            
        case .validatedSelection(let kitchenwareCellModels):
            let kitchenwares = kitchenwareCellModels.compactMap { $0.kitchenware }
            return send(report: .finishedSelection(kitchenwares), env)
            
        case .recoverFromFailure(.validatingSelection(let error)):
            log.error("Unable to validate kitchenware selection : \(error)")
            state.isLoading = false
//            state.errorAlert = .defaultError(acknowledge: .acknowledgeError)
            
        case .recoverFromFailure(.fetchingSelectedAppliance(let error)):
            log.error("Unable to load selected appliance : \(error)")
            state.isLoading = false
//            state.errorAlert = .defaultError(acknowledge: .report(.finishedSelection([])))
            
        case .acknowledgeError:
            break
//            state.errorAlert = nil
            
        case .dismissKitchenwareDetail:
            state.kitchenwareDetail = nil
            
        case .kitchenwareDetail:
            break // handled by child
            
        case .report:
            // Handled by parent
            break
        }
        return .none
    }
    .combined(with: analyticsMiddleware)
    .combined(with: kitchenwareDetailReducer)
    }
    
    private static var kitchenwareDetailReducer: Self.Reducer { Cores.KitchenwareDetailCore.reducer(
        state: \State.kitchenwareDetail,
        action: /Action.kitchenwareDetail,
        environment: { $0.kitchenwareDetail },
        dependencies: .none
    )}
    
    static func send(report: Report, _ env: Environment) -> Effect<Action, Never> {
        if let navigationHandler = env.navigationHandler { // when displayed from coordinator
            navigationHandler(report)
            return .none
        } else {
            return .just(.report(report))
        }
    }
}

private extension KitchenwareListCore {
    static func splitKitchenwares(
        _ kitchenwares: [Kitchenware],
        disclosureType: DisclosureType,
        selectionPossible: Bool,
        alreadySelectedKitchenwares: [KitchenwareId]
    ) -> [KitchenwareCellModel] {
        kitchenwares
            .filter { $0.isSelectable }
            .map { kitchenware in
                    .init(
                        disclosureType: disclosureType,
                        isSelected: selectionPossible
                        && alreadySelectedKitchenwares.contains(kitchenware.key),
                        kitchenware: kitchenware
                    )
            }
            .sorted(by: { $0.key < $1.key })
    }
}

/// Adds equality to any kind of error.
/// Particularly useful inside Composable architecture states & actions
/// The equality will be based on the `reason`'s `localizedDescription`
public struct EquatableError: Error, Equatable {
    public static func == (lhs: EquatableError, rhs: EquatableError) -> Bool {
        return lhs.reason.localizedDescription == rhs.reason.localizedDescription
    }

    /// The wrapped error
    public let reason: Error
}

extension EquatableError: CustomDebugStringConvertible {
    public var localizedDescription: String {
        reason.localizedDescription
    }
    
    public var debugDescription: String {
        "\(reason)"
    }
}

extension Error {
    /// Wraps current in an `EquatableError`.
    /// The equality will be based on its `localizedDescription`
    public var equatable: EquatableError {
        .init(reason: self)
    }
}

/// Replaces the definition from GSMODCore
let log = SwiftyBeaver.self
