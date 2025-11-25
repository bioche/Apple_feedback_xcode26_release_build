//
//  ApplianceListCore.swift
//
//
//  Created by Samir Tiouajni on 01/06/2024.
//

import GSMODApplianceSelectionComposableInterfaces
import RxComposableArchitecture
import RxSwift


import GSMODApplianceSelectionKit

public struct ApplianceListCore<Cores: ApplianceCoreInterfaces>: TCACore {

    public struct State: Equatable {

        var appliances: [Appliance]

        // Auto detection
        var shouldAutoDetectAppliances: Bool = false
        var nearbyAppliances: [Appliance] = []

        var applianceDomainConfigurations: [RawDomain: ApplianceDomainConfiguration]
        /// After declaration, we ignore pop to root in some cases
        ///  if we don't have many domains
        var shouldIgnorePopToRoot: Bool
        var chosenAppliance: Appliance?

        @CopyOnWrite var capacitySelection: CapacitySelectionCore.State?
        @CopyOnWrite var applianceDeclaration: ApplianceDeclarationCore<Cores>.State?

        public static func initial(
            appliances: [Appliance],
            applianceDomainConfigurations: [RawDomain: ApplianceDomainConfiguration],
            shouldIgnorePopToRoot: Bool
        ) -> Self {
            .init(
                appliances: appliances.sorted(by: { ($0.order ?? .min) > ($1.order ?? .min) }),
                applianceDomainConfigurations: applianceDomainConfigurations,
                shouldIgnorePopToRoot: shouldIgnorePopToRoot
            )
        }
    }

    public enum Report: Equatable {
        case userTappedValidation([SelectedAppliance])
        case popToRoot
        case deniedCreation(Appliance, String, Bool)
    }

    public enum Action: Equatable {
        /// For Analytics
        case didAppear

        case userTappedNearbyAppliance(Appliance)
        case userTappedApplianceCell(Appliance)

        case dismissCapacitySelection

        case updateNearbyAppliances([ApplianceId])

        case displayApplianceDeclaration(Appliance, Capacity?, isAutoDetected: Bool)
        case dismissApplianceDeclaration

        case report(Report)
        case error(EquatableError)

        case capacitySelection(CapacitySelectionCore.Action)
        case applianceDeclaration(ApplianceDeclarationCore<Cores>.Action)
    }

    public struct Environment: TrackedCoreEnvironment {

        var applianceDeclaration: ApplianceDeclarationCore<Cores>.Environment
        var autoDetectionService: AutoDetectionService?

        public static func live(
            servicesFactory: ApplianceServicesFactory,
            base: Cores.BaseEnvironment
        ) -> Self {
            .init(
                applianceDeclaration: .live(
                    servicesFactory: servicesFactory,
                    base: base
                ),
                autoDetectionService: servicesFactory.autoDetectionService
            )
        }

        public static func mock(
            servicesFactory: ApplianceServicesFactory,
            base: Cores.BaseEnvironment
        ) -> Self {
            .init(
                applianceDeclaration: .mock(
                    servicesFactory: servicesFactory,
                    base: base
                )
            )
        }
    }

    public static var featureReducer: Self.Reducer { .init { state, action, env in
        switch action {
        case .didAppear:
            if let autoDetectionService = env.autoDetectionService {
                state.shouldAutoDetectAppliances = true
                return autoDetectionService.startAppliancesDiscovery()
                    .asObservable()
                    .catchToResult()
                    .splitResultToActionEffect(
                        action: {
                            return .updateNearbyAppliances($0)
                        },
                        failureAction: {
                            return .error($0.equatable)
                        }
                    )
            }

        case .updateNearbyAppliances(let applianceIds):
            /// Use already loaded appliance to display nearbyProducts
            /// Also, it prevent to display a nearby product if it's not in the list (ex: not supported in the lang/market)
            state.nearbyAppliances = applianceIds.compactMap { applianceId in
                state.appliances.first { $0.applianceId == applianceId }
            }

        case .userTappedNearbyAppliance(let appliance):
            state.chosenAppliance = appliance
            if let defaultCapacity = appliance.capacities.first {
                state.capacitySelection = .initial(
                    configuration: .init(
                        capacities: appliance.capacities,
                        defaultCapacity: defaultCapacity
                    )
                )
                break
            }
            return .just(.displayApplianceDeclaration(appliance, nil, isAutoDetected: true))

        case .userTappedApplianceCell(let appliance):
            state.chosenAppliance = appliance
            /// Check if the appliance has capacities to display capacity picker
            if let defaultCapacity = appliance.capacities.first {
                state.capacitySelection = .initial(
                    configuration: .init(
                        capacities: appliance.capacities,
                        defaultCapacity: defaultCapacity
                    )
                )
                break
            }
            return .just(.displayApplianceDeclaration(appliance, nil, isAutoDetected: false))

        case .displayApplianceDeclaration(let appliance, let capacity, let isAutoDetected):
            state.applianceDeclaration = .initial(
                appliance: appliance,
                isAutoDetected: isAutoDetected,
                selectedCapacity: capacity,
                domainName: DomainInfo.domainName(
                    for: appliance.rawDomain,
                    state.applianceDomainConfigurations
                ),
                shouldIgnorePopToRoot: state.shouldIgnorePopToRoot
            )
            /// We start the applianceDeclaration for make like ViewDidLoad (Appear one time)
            return .just(.applianceDeclaration(.didAppear))

        case .dismissApplianceDeclaration:
            state.applianceDeclaration = nil

        case .dismissCapacitySelection:
            state.capacitySelection = nil

        case .applianceDeclaration(.report(let report)):
            switch report {
            case .popToRootView:
                return .just(.report(.popToRoot))
            case .validated(let selectedAppliance):
                return .just(.report(.userTappedValidation([selectedAppliance])))
            case .deniedCreation(let appliance, let nickname, let isAutoDetected):
                return .just(.report(.deniedCreation(appliance, nickname, isAutoDetected)))
            }

        case .capacitySelection(.report(let report)):
            switch report {
            case .userSelectedCapacity(let capacity):
                guard let appliance = state.chosenAppliance else {
                    state.capacitySelection = nil
                    break
                }
                state.capacitySelection = nil
                return .just(.displayApplianceDeclaration(appliance, capacity, isAutoDetected: false))

            case .userTappedCancel:
                state.capacitySelection = nil
            }

        case .capacitySelection, .applianceDeclaration:
            break // handled by child

        case .error(let error):
            log.error("ApplianceListCore error: \(error)")

        case .report:
            break // handled by parent
        }
        return .none
    }
    .combined(with: analyticsMiddleware)
    .combined(with: capacitySelectionReducer)
    .combined(with: applianceDeclarationReducer)
    }

    private static var capacitySelectionReducer: Self.Reducer { CapacitySelectionCore.reducer(
        state: \State.capacitySelection,
        action: /Action.capacitySelection,
        environment: { _ in .init() },
        dependencies: .none
    )}

    private static var applianceDeclarationReducer: Self.Reducer { ApplianceDeclarationCore<Cores>.reducer(
        state: \State.applianceDeclaration,
        action: /Action.applianceDeclaration,
        environment: { $0.applianceDeclaration },
        dependencies: .none
    )}
}
