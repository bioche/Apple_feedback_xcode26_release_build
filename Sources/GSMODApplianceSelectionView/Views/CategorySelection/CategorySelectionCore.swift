//
//  CategorySelectionCore.swift
//
//
//  Created by Samir Tiouajni on 02/06/2024.
//

import GSMODApplianceSelectionComposableInterfaces
import RxComposableArchitecture


import GSMODApplianceSelectionKit

import Foundation

enum SAVExternalLinkStatus: Equatable {
    case loading, loaded(String?)
}

// swiftlint:disable:next type_body_length
public struct CategorySelectionCore<Cores: ApplianceCoreInterfaces>: TCACore {
    
    public struct State: Equatable {
        
        var savContent: SAVContent?
        var savExternalLink: SAVExternalLinkStatus = .loading
        var categorySelectionType: CategorySelectionType
        var applianceEditableLaterLabelHidden: Bool
        
        var selectedProducts: [CategorySelectionCore.Product]
        /// After declaration, we ignore pop to root in some cases
        ///  if we don't have many domains
        var shouldIgnorePopToRoot: Bool
        
        var showSelectedAppliances: Bool {
            return (selectedProducts.count > 0 && categorySelectionType.isDomain) || allowMultipleAppliancesPerDomain
        }
        
        var allowMultipleAppliancesPerDomain: Bool
        var shouldDisplayInformation: Bool
        
        var availableCategories: [Category] {
            var availableCategories: [Category] = []
            
            if allowMultipleAppliancesPerDomain || !categorySelectionType.isDomain {
                // if more than one appliance/domain is allowed, no need to filter
                availableCategories = categorySelectionType.categories
            } else {
                // if only one appliance/domain allowed, filter on selected appliances domains
                let ids: [String] = selectedProducts.map { $0.selectedAppliance.rawDomain }
                availableCategories = categorySelectionType
                    .categories
                    .filter {
                        return !ids.contains($0.id)
                    }
            }
            
            // return sorted categories
            return availableCategories
                .sorted(
                    by: {
                        guard $0.order != $1.order else {
                            return $0.name < $1.name
                        }
                        return $0.order ?? .max < $1.order ?? .max
                    }
                )
        }
        
        /// we declared familySelection state that have same type of our State to push
        /// same screen with different values
        @CopyOnWrite var familySelection: CategorySelectionCore<Cores>.State?
        @CopyOnWrite var applianceList: ApplianceListCore<Cores>.State?
        @CopyOnWrite var productDetails: ProductDetailsCore<Cores>.State?
        @CopyOnWrite var applianceDeclaration: ApplianceDeclarationCore<Cores>.State?
        
        public static func initial(
            categorySelectionType: CategorySelectionType,
            applianceEditableLaterLabelHidden: Bool,
            shouldIgnorePopToRoot: Bool,
            allowMultipleAppliancesPerDomain: Bool,
            shouldDisplayInformation: Bool
        ) -> Self {
            .init(
                categorySelectionType: categorySelectionType,
                applianceEditableLaterLabelHidden: applianceEditableLaterLabelHidden,
                selectedProducts: [], 
                shouldIgnorePopToRoot: shouldIgnorePopToRoot,
                allowMultipleAppliancesPerDomain: allowMultipleAppliancesPerDomain,
                shouldDisplayInformation: shouldDisplayInformation
            )
        }
    }
    
    public enum Report: Equatable {
        case userTappedValidation([SelectedAppliance])
        case popToRoot
        case deniedCreation(Appliance, String, isAutoDetected: Bool)
    }
    
    /// we used the keyword 'indirect' because Action enum  need to reference itself
    /// with 'familySelection' case
    public indirect enum Action: Equatable {
        case didAppear
        /// For Analytics
        case savViewDidAppear
        
        case fetchSelectedProducts
        case updateProducts([CategorySelectionCore.Product])
        
        case userTappedProductDetails(CategorySelectionCore.Product)
        case userTappedCategory(Category)
        
        case displayApplianceList([Appliance])
        case dismissApplianceList
        
        case displayApplianceFamilySelection(DomainInfo)
        case dismissFamilySelection
        
        case dismissProductDetails
        
        case displayApplianceDeclaration(Appliance, domainName: String)
        case dismissApplianceDeclaration
        
        case userTappedSAVDetail(URL)
        case userTappedSAVButton // For analytics
        case leaveSAVDetail
        
        case handleError(EquatableError)
        
        case fetchSAVExternalLink
        case fetchedSAVExternalLink(String?)
        
        case report(Report)
        
        case familySelection(CategorySelectionCore<Cores>.Action)
        case applianceList(ApplianceListCore<Cores>.Action)
        case productDetails(ProductDetailsCore<Cores>.Action)
        case applianceDeclaration(ApplianceDeclarationCore<Cores>.Action)
    }
    
    public struct Environment: TrackedCoreEnvironment {
        
        let selectedApplianceService: SelectedAppliancesService
        let kitchenwaresService: KitchenwaresService
        /// we used the class 'StatefulEnvironment' because Environment struct  need to reference itself
        var familySelection: StatefulEnvironment<CategorySelectionCore<Cores>.Environment>
        var applianceList: ApplianceListCore<Cores>.Environment
        var productDetails: ProductDetailsCore<Cores>.Environment
        var applianceDeclaration: ApplianceDeclarationCore<Cores>.Environment
        var servicesFactory: ApplianceServicesFactory
        let configuration: ApplianceConfiguration
        
        public static func live(
            servicesFactory: ApplianceServicesFactory,
            base: Cores.BaseEnvironment,
            productDetailUIDatasource: ProductDetailUIDatasource
        ) -> Self {
            .init(
                selectedApplianceService: servicesFactory.buildSelectedAppliancesService(),
                kitchenwaresService: servicesFactory.buildKitchenwaresService(), 
                familySelection: .stateful(
                    .live(
                        servicesFactory: servicesFactory,
                        base: base,
                        productDetailUIDatasource: productDetailUIDatasource
                    )
                ),
                applianceList: .live(
                    servicesFactory: servicesFactory,
                    base: base
                ),
                productDetails: .live(
                    servicesFactory: servicesFactory, 
                    base: base,
                    productDetailUIDatasource: productDetailUIDatasource
                ), 
                applianceDeclaration: .live(
                    servicesFactory: servicesFactory,
                    base: base
                ),
                servicesFactory: servicesFactory,
                configuration: servicesFactory.configuration
            )
        }
        
        public static func mock(
            servicesFactory: ApplianceServicesFactory,
            base: Cores.BaseEnvironment
        ) -> Self {
            .init(
                selectedApplianceService: servicesFactory.buildSelectedAppliancesService(),
                kitchenwaresService: servicesFactory.buildKitchenwaresService(),
                familySelection: .stateful(
                    .mock(
                        servicesFactory: servicesFactory,
                        base: base
                    )
                ),
                applianceList: .mock(
                    servicesFactory: servicesFactory,
                    base: base
                ),
                productDetails: .mock(
                    servicesFactory: servicesFactory,
                    base: base
                ),
                applianceDeclaration: .mock(
                    servicesFactory: servicesFactory,
                    base: base
                ),
                servicesFactory: servicesFactory,
                configuration: servicesFactory.configuration
            )
        }
    }
    
    public static var featureReducer: Self.Reducer { .init { state, action, env in
        switch action {
        case .savViewDidAppear:
            break /// For Analytics
            
        case .didAppear:
            return .concatenate(
                .just(.fetchSAVExternalLink),
                .just(.fetchSelectedProducts)
            )
            
        case .fetchSAVExternalLink:
            if let action = env.servicesFactory.fetchSAVUrlPath {
                return action()
                    .catchToResult()
                    .splitResultToActionEffect(
                        action: { .fetchedSAVExternalLink($0) },
                        failureAction: { .handleError($0.equatable) }
                    )
            }
            
        case .fetchedSAVExternalLink(let link):
            state.savExternalLink = .loaded(link)
            
        case .fetchSelectedProducts:
            return fetchSelectedProducts(state: state, env: env)
            
        case .updateProducts(let products):
            state.selectedProducts = products
            
        case .handleError(let error):
            log.error("ApplianceDeclarationCore error: \(error)")
            
        case .userTappedCategory(let category):
            switch state.categorySelectionType {
            case .domain(let domainInfos, _):
                guard let domainInfo = domainInfos
                    .first(where: { $0.domain == category.id }) else { break }
                return categoriesNavigation(env, domainInfo)
            case .family(let domainInfo, _):
                return familiesNavigation(env, domainInfo, category.id)
            }
            
        case .dismissApplianceList:
            state.applianceList = nil
            
        case .userTappedProductDetails(let product):
            state.productDetails = .initial(
                productId: product.selectedAppliance.productId,
                isUserConnected: false,
                shouldDisplayInformation: state.shouldDisplayInformation,
                brandName: env.configuration.brandName,
                selectedCapacity: product.selectedAppliance.selectedCapacity?.description,
                applianceDomainConfigurations: env.configuration.applianceDomainConfigurations
            )
            
        case .userTappedSAVDetail(let savExternalLink):
            state.savContent = .init(
                isPremium: env.configuration.isPremium,
                externalLink: savExternalLink
            )
            
        case .displayApplianceDeclaration(let appliance, let domainName):
            state.applianceDeclaration = .initial(
                capacityPickerDisplayed: appliance.capacities.isNotEmpty,
                appliance: appliance,
                isAutoDetected: false,
                selectedCapacity: nil,
                domainName: domainName, 
                shouldIgnorePopToRoot: state.shouldIgnorePopToRoot
            )
            return .just(.applianceDeclaration(.didAppear))
            
        case .displayApplianceList(let appliances):
            state.applianceList = .initial(
                appliances: appliances,
                applianceDomainConfigurations: env.configuration.applianceDomainConfigurations, 
                shouldIgnorePopToRoot: state.shouldIgnorePopToRoot
            )
            
        case .displayApplianceFamilySelection(let domainInfo):
            state.familySelection = .initial(
                categorySelectionType: .family(
                    domainInfo,
                    env.configuration.applianceDomainConfigurations
                ),
                applianceEditableLaterLabelHidden: state.applianceEditableLaterLabelHidden, 
                shouldIgnorePopToRoot: state.shouldIgnorePopToRoot,
                allowMultipleAppliancesPerDomain: state.allowMultipleAppliancesPerDomain,
                shouldDisplayInformation: false
            )
            
        case .leaveSAVDetail:
            state.savContent = nil
            
        case .dismissFamilySelection:
            state.familySelection = nil
            
        case .dismissApplianceDeclaration:
            state.applianceDeclaration = nil
            
        case .dismissProductDetails:
            state.productDetails = nil
            
        case .productDetails(.report(let report)):
            switch report {
            case .deleted:
                return .just(.dismissProductDetails)
            case .requestedManual:
                // we don't need because we don't display information
                break
            case .closed:
                // we don't need because product detail is integrate in existant stack
                break
            }
            
        case .applianceList(.report(let report)):
            switch report {
            case .popToRoot:
                return .just(.report(.popToRoot))
            case .userTappedValidation(let selectedAppliances):
                return .just(.report(.userTappedValidation(selectedAppliances)))
            case .deniedCreation(let appliance, let nickname, let isAutoDetected):
                return .just(.report(.deniedCreation(appliance, nickname, isAutoDetected: isAutoDetected)))
            }
            
        case .applianceDeclaration(.report(let report)):
            switch report {
            case .popToRootView:
                return .just(.report(.popToRoot))
            case .validated(let selectedAppliance):
                return .just(.report(.userTappedValidation([selectedAppliance])))
            case .deniedCreation(let appliance, let nickname, let isAutoDetected):
                return .just(.report(.deniedCreation(appliance, nickname, isAutoDetected: isAutoDetected)))
            }
            
        case .familySelection(.report(let report)):
            switch report {
            case .userTappedValidation(let selectedAppliances):
                return .just(.report(.userTappedValidation(selectedAppliances)))
            case .popToRoot:
                return .just(.report(.popToRoot))
            case .deniedCreation(let appliance, let nickname, let isAutoDetected):
                return .just(.report(.deniedCreation(appliance, nickname, isAutoDetected: isAutoDetected)))
            }
            
        case .applianceList, .productDetails, .familySelection, .applianceDeclaration:
            break // handled by child
            
        case .report, .userTappedSAVButton:
            break // handled by parent
        }
        return .none
    }
    .combined(with: analyticsMiddleware)
    .combined(with: applianceListReducer)
    .combined(with: productDetailsReducer)
    .combined(with: applianceDeclarationReducer)
    /// we used 'familySelectionReducer(&$0, $1, $2) 'because reducer state, action, environment references themselves
    .combined(with: .init { familySelectionReducer(&$0, $1, $2) })
    }
    
    static var familySelectionReducer: Self.Reducer { CategorySelectionCore<Cores>.reducer(
        state: \State.familySelection,
        action: /Action.familySelection,
        environment: { $0.familySelection.value },
        dependencies: .none
    )}
    
    private static var applianceListReducer: Self.Reducer { ApplianceListCore<Cores>.reducer(
        state: \State.applianceList,
        action: /Action.applianceList,
        environment: { $0.applianceList },
        dependencies: .none
    )}
    
    private static var productDetailsReducer: Self.Reducer { ProductDetailsCore<Cores>.reducer(
        state: \State.productDetails,
        action: /Action.productDetails,
        environment: { $0.productDetails },
        dependencies: .none
    )}
    
    private static var applianceDeclarationReducer: Self.Reducer { ApplianceDeclarationCore<Cores>.reducer(
        state: \State.applianceDeclaration,
        action: /Action.applianceDeclaration,
        environment: { $0.applianceDeclaration },
        dependencies: .none
    )}
}
