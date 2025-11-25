//
//  ApplianceFirstSelectionCore.swift
//
//
//  Created by Samir Tiouajni on 03/06/2024.
//

import GSMODApplianceSelectionComposableInterfaces
import RxComposableArchitecture


import GSMODApplianceSelectionKit


/// case 1: more than one domain -> CategorySelection(Domain)
/// case 2: one domain
///   - many families -> CategorySelection(FamilySelection)
///   - one family
///        * many appliances -> ApplianceList
///        * one appliance -> ApplianceDeclaration

public struct ApplianceFirstSelectionCore<Cores: ApplianceCoreInterfaces>: TCACore {
    
    public struct State: Equatable {
        
        var applianceEditableLaterLabelHidden: Bool
        var isLoading: Bool
        var isFailed: Bool
        /// Multiple appliances per domain is allowed
        var allowMultipleAppliancesPerDomain: Bool
        /// From pure air we need to allow displaying product informations in productDetailsView
        var shouldDisplayInformation: Bool
        var isBackButtonDisplayed: Bool = false
        
        @CopyOnWrite var domainSelection: CategorySelectionCore<Cores>.State?
        @CopyOnWrite var applianceList: ApplianceListCore<Cores>.State?
        @CopyOnWrite var applianceDeclaration: ApplianceDeclarationCore<Cores>.State?
        
        public static func initial(
            applianceEditableLaterLabelHidden: Bool,
            allowMultipleAppliancesPerDomain: Bool,
            shouldDisplayInformation: Bool = false,
            isBackButtonDisplayed: Bool
        ) -> Self {
            .init(
                applianceEditableLaterLabelHidden: applianceEditableLaterLabelHidden,
                isLoading: false,
                isFailed: false,
                allowMultipleAppliancesPerDomain: allowMultipleAppliancesPerDomain,
                shouldDisplayInformation: shouldDisplayInformation,
                isBackButtonDisplayed: isBackButtonDisplayed
            )
        }
    }
    
    public enum Report: Equatable {
        /// The user chose to validate its selection & should leave the module
        case validated(selectedAppliances: [SelectedAppliance])
        /// When app has refused to create product on selection
        case deniedCreation(selectedAppliance: Appliance, nickname: String, isAutoDetected: Bool)
    }
    
    public enum Action: Equatable {
        case applyReload
        
        case fetchAppliances
        case fetchedAppliancesSuccess([Appliance])
        
        case displayDomainSelection([DomainInfo])
        case displayApplianceList([Appliance])
        case displayApplianceFamilySelection(DomainInfo)
        case displayApplianceDeclaration(Appliance, domainName: String, isAutoDetected: Bool)

        case handleError(EquatableError)
        
        case domainSelection(CategorySelectionCore<Cores>.Action)
        case applianceList(ApplianceListCore<Cores>.Action)
        case applianceDeclaration(ApplianceDeclarationCore<Cores>.Action)
        
        case report(Report)
    }
    
    public struct Environment: TrackedCoreEnvironment {
        
        let appliancesService: AppliancesService
        let kitchenwaresService: KitchenwaresService
        let selectedAppliancesService: SelectedAppliancesService
        
        var domainSelection: CategorySelectionCore<Cores>.Environment
        var applianceList: ApplianceListCore<Cores>.Environment
        var applianceDeclaration: ApplianceDeclarationCore<Cores>.Environment
        
        let configuration: ApplianceConfiguration
        
        public static func live(
            servicesFactory: ApplianceServicesFactory,
            base: Cores.BaseEnvironment,
            productDetailUIDatasource: ProductDetailUIDatasource
        ) -> Self {
            .init(
                appliancesService: servicesFactory.buildAppliancesService(),
                kitchenwaresService: servicesFactory.buildKitchenwaresService(),
                selectedAppliancesService: servicesFactory.buildSelectedAppliancesService(),
                domainSelection: .live(
                    servicesFactory: servicesFactory,
                    base: base,
                    productDetailUIDatasource: productDetailUIDatasource
                ),
                applianceList: .live(
                    servicesFactory: servicesFactory,
                    base: base
                ),
                applianceDeclaration: .live(
                    servicesFactory: servicesFactory,
                    base: base
                ),
                configuration: servicesFactory.configuration
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
                domainSelection: .mock(
                    servicesFactory: servicesFactory,
                    base: base
                ),
                applianceList: .mock(
                    servicesFactory: servicesFactory,
                    base: base
                ),
                applianceDeclaration: .mock(
                    servicesFactory: servicesFactory,
                    base: base
                ),
                configuration: servicesFactory.configuration
            )
        }
    }
    
    public static var featureReducer: Self.Reducer { .init { state, action, env in
        switch action {
        case .applyReload:
            state.isFailed = false
            return .just(.fetchAppliances)
            
        case .fetchAppliances:
            state.isLoading = true
            return fetchAppliances(state, env)
            
        case .fetchedAppliancesSuccess(let appliances):
            state.isLoading = false
            return setNavigation(env, appliances, state.allowMultipleAppliancesPerDomain)
            
        case .handleError(let error):
            log.info("ApplianceFirstSelectionCore fetchAppliances error \(error)")
            state.isLoading = false
            state.isFailed = true
            
        case .displayDomainSelection(let domainInfos):
            state.domainSelection = .initial(
                categorySelectionType: .domain(
                    domainInfos,
                    env.configuration.applianceDomainConfigurations
                ), 
                applianceEditableLaterLabelHidden: state.applianceEditableLaterLabelHidden, 
                shouldIgnorePopToRoot: false,
                allowMultipleAppliancesPerDomain: state.allowMultipleAppliancesPerDomain,
                shouldDisplayInformation: state.shouldDisplayInformation
            )
            
        case .displayApplianceDeclaration(let appliance, let domainName, let isAutoDetected):
            state.applianceDeclaration = .initial(
                capacityPickerDisplayed: appliance.capacities.isNotEmpty,
                appliance: appliance,
                isAutoDetected: isAutoDetected,
                selectedCapacity: nil,
                domainName: domainName, 
                shouldIgnorePopToRoot: true
            )
            return .just(.applianceDeclaration(.didAppear))
            
        case .displayApplianceList(let appliances):
            state.applianceList = .initial(
                appliances: appliances,
                applianceDomainConfigurations: env.configuration.applianceDomainConfigurations, 
                shouldIgnorePopToRoot: true
            )
            
        case .displayApplianceFamilySelection(let domainInfo):
            state.domainSelection = .initial(
                categorySelectionType: .family(
                    domainInfo,
                    env.configuration.applianceDomainConfigurations
                ), 
                applianceEditableLaterLabelHidden: state.applianceEditableLaterLabelHidden,
                shouldIgnorePopToRoot: true,
                allowMultipleAppliancesPerDomain: state.allowMultipleAppliancesPerDomain,
                shouldDisplayInformation: state.shouldDisplayInformation
            )
            
        case .domainSelection(.report(let report)):
            switch report {
            case .userTappedValidation(let selectedAppliances):
                return .just(.report(.validated(selectedAppliances: selectedAppliances)))
            case .popToRoot:
                state.domainSelection = nil
            case .deniedCreation(let appliance, let nickname, let isAutoDetected):
                return .just(
                    .report(
                        .deniedCreation(
                            selectedAppliance: appliance,
                            nickname: nickname,
                            isAutoDetected: isAutoDetected
                        )
                    )
                )
            }
            
        case .applianceList(.applianceDeclaration(.report(let report))):
            switch report {
            case .popToRootView:
                state.applianceList = nil
            case .validated(let selectedAppliance):
                return .just(.report(.validated(
                    selectedAppliances: [selectedAppliance]
                )))
            case .deniedCreation(let appliance, let nickname, let isAutoDetected):
                return .just(
                    .report(
                        .deniedCreation(
                            selectedAppliance: appliance,
                            nickname: nickname,
                            isAutoDetected: isAutoDetected
                        )
                    )
                )
            }
            
        case .applianceDeclaration(.report(let report)):
            switch report {
            case .popToRootView:
                state.applianceDeclaration = nil
            case .validated(let selectedAppliance):
                return .just(.report(.validated(
                    selectedAppliances: [selectedAppliance]
                )))
            case .deniedCreation(let appliance, let nickname, let isAutoDetected):
                return .just(
                    .report(
                        .deniedCreation(
                            selectedAppliance: appliance,
                            nickname: nickname,
                            isAutoDetected: isAutoDetected
                        )
                    )
                )
            }
            
        case .domainSelection, .applianceList, .applianceDeclaration:
            break // handled by child
            
        case .report:
            break // handled by parent
        }
        return .none
    }
    .combined(with: categorySelectionReducer)
    .combined(with: applianceListReducer)
    .combined(with: applianceDeclarationReducer)
    }
    
    private static var applianceListReducer: Self.Reducer { ApplianceListCore<Cores>.reducer(
        state: \State.applianceList,
        action: /Action.applianceList,
        environment: { $0.applianceList },
        dependencies: .none
    )}
    
    private static var categorySelectionReducer: Self.Reducer { CategorySelectionCore<Cores>.reducer(
        state: \State.domainSelection,
        action: /Action.domainSelection,
        environment: { $0.domainSelection },
        dependencies: .none
    )}
    
    private static var applianceDeclarationReducer: Self.Reducer { ApplianceDeclarationCore<Cores>.reducer(
        state: \State.applianceDeclaration,
        action: /Action.applianceDeclaration,
        environment: { $0.applianceDeclaration },
        dependencies: .none
    )}
}
