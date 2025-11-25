//
//  ApplianceDeclarationCore.swift
//
//
//  Created by Samir Tiouajni on 01/06/2024.
//


import RxComposableArchitecture

import GSMODApplianceSelectionKit



import GSMODApplianceSelectionComposableInterfaces

import RxSwift

public struct ApplianceDeclarationCore<Cores: ApplianceCoreInterfaces>: TCACore {
    
    public struct State: Equatable {
        
        var chosenAppliance: Appliance
        let isAutoDetected: Bool
        var applianceNickname: String
        var selectedCapacity: Capacity?
        var kitchenwareAvailable: Bool
        var selectedKitchenwares: [Kitchenware]
        
        var domainName: String
        
        var isLoading: Bool
        
        /// To display capacity picker when we came from domain or family mono-appliance
        ///  To update default capacity
        var capacityPickerDisplayed: Bool
        /// After declaration, we ignore pop to root in some cases
        ///  if we don't have many domains
        var shouldIgnorePopToRoot: Bool
        
        var groupId: ApplianceId {
            chosenAppliance.groupId
        }
        
        var capacity: String {
            guard let capacity = selectedCapacity else { return "" }
            return capacity.description
        }
        
        var selectedKitchenwaresCount: Int {
            selectedKitchenwares.count
        }
        
        var errorAlert: AlertState<Action>?
        @CopyOnWrite var kitchenwareList: KitchenwareListCore<Cores>.State?
        @CopyOnWrite var capacitySelection: CapacitySelectionCore.State?
        
        public static func initial(
            capacityPickerDisplayed: Bool = false,
            appliance: Appliance,
            isAutoDetected: Bool,
            selectedCapacity: Capacity?,
            domainName: String,
            shouldIgnorePopToRoot: Bool
        ) -> Self {
            .init(
                chosenAppliance: appliance,
                isAutoDetected: isAutoDetected,
                applianceNickname: appliance.name,
                selectedCapacity: selectedCapacity,
                kitchenwareAvailable: false, 
                selectedKitchenwares: [], 
                domainName: domainName,
                isLoading: false, 
                capacityPickerDisplayed: capacityPickerDisplayed, 
                shouldIgnorePopToRoot: shouldIgnorePopToRoot
            )
        }
    }
    
    public enum Report: Equatable {
        /// After validate declared appliance, we pop views to root
        case popToRootView
        /// This action is when we have one appliance in the app (no domains, no families)
        case validated(selectedAppliance: SelectedAppliance)
        /// When app has refused to create product on selection
        case deniedCreation(selectedAppliance: Appliance, nickname: String, isAutoDetected: Bool)
    }
    
    public enum Action: Equatable {
        case didAppear
        
        case fetchKitchenwares
        case updateKitchenwares([Kitchenware])
        case fetchedKitchenwareIds([KitchenwareId])
        
        case fetchedSelectedAppliance(SelectedAppliance?)
        case updatedSelectedApplianceSuccess(SelectedAppliance)

        /// To update Appliance with
        case updateSelectedAppliance(SelectedAppliance)
        
        /// Actions to adapt ApplianceDeclarationCore to ApplianceHeaderViewState
        case saveNickname
        case updateNickname(String)
        case setNickName(Bool)
        
        case userTappedValidateButton
        
        case userTappedDisplayKitchenware(Appliance, [Kitchenware])
        case dismissKitchenwareList
        
        case displayCapacityPicker
        case dismissCapacitySelection
        
        case handleError(EquatableError)
        
        case dismissAlert
        
        case report(Report)
        
        case capacitySelection(CapacitySelectionCore.Action)
        case kitchenwareList(KitchenwareListCore<Cores>.Action)
    }
    
    public struct Environment: TrackedCoreEnvironment {
        
        // MARK: - Services
        let appliancesService: AppliancesService
        let kitchenwaresService: KitchenwaresService
        let selectedAppliancesService: SelectedAppliancesService
        let autoDetectionService: AutoDetectionService?

        var kitchenwareList: KitchenwareListCore<Cores>.Environment
        
        public static func live(
            servicesFactory: ApplianceServicesFactory,
            base: Cores.BaseEnvironment
        ) -> Self {
            .init(
                appliancesService: servicesFactory.buildAppliancesService(),
                kitchenwaresService: servicesFactory.buildKitchenwaresService(),
                selectedAppliancesService: servicesFactory.buildSelectedAppliancesService(),
                autoDetectionService: servicesFactory.autoDetectionService,
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
                autoDetectionService: servicesFactory.autoDetectionService,
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
            if state.capacityPickerDisplayed {
                return .concatenate(
                    .just(.displayCapacityPicker),
                    .just(.fetchKitchenwares)
                )
            }
            return .just(.fetchKitchenwares)
            
        case .fetchKitchenwares:
            return env.kitchenwaresService
                .getKitchenwares(applianceGroup: state.groupId)
                .catchToResult()
                .splitResultToActionEffect(
                    action: { .updateKitchenwares($0) },
                    failureAction: { .handleError($0.equatable) }
                )
            
        case .updateKitchenwares(let kitchenwares):
            state.kitchenwareAvailable = kitchenwares.filter { $0.isSelectable }.count > 0
            state.selectedKitchenwares = kitchenwares.filter { $0.isInPack && $0.isSelectable }
            
        case .userTappedValidateButton:
            state.isLoading = true
            return env.kitchenwaresService
                .getKitchenwares(applianceGroup: state.groupId)
                .map({ $0.allInPack.map({ $0.key }) })
                .catchToResult()
                .splitResultToActionEffect(
                    action: { .fetchedKitchenwareIds($0) },
                    failureAction: { .handleError($0.equatable) }
                )
            
        case .fetchedKitchenwareIds(let kitchenwareIds):
            let nickname = state.applianceNickname.isEmpty
            ? state.chosenAppliance.name : state.applianceNickname
            
            return env.selectedAppliancesService
                .addSelectedAppliance(
                    appliance: state.chosenAppliance,
                    capacity: state.selectedCapacity,
                    kitchenwareIds: kitchenwareIds,
                    nickname: nickname
                )
                .catchToResult()
                .splitResultToActionEffect(
                    action: { .fetchedSelectedAppliance($0) },
                    failureAction: { .handleError($0.equatable) }
                )
            
        case .fetchedSelectedAppliance(let selectedAppliance):
            guard var selectedAppliance = selectedAppliance else {
                state.isLoading = false
                return .just(
                    .report(
                        .deniedCreation(
                            selectedAppliance: state.chosenAppliance,
                            nickname: state.applianceNickname,
                            isAutoDetected: state.isAutoDetected
                        )
                    )
                )
            }
            
            var selectedKitchenwares: [KitchenwareId] {
                state.selectedKitchenwares.isNotEmpty
                ? state.selectedKitchenwares.map { $0.key } : []
            }
            selectedAppliance.selectedKitchenware = selectedKitchenwares
            return .just(.updateSelectedAppliance(selectedAppliance))

        case .updateSelectedAppliance(let selectedAppliance):
            return env.selectedAppliancesService
                .updateSelectedAppliance(selectedAppliance)
                .catchToResult()
                .splitResultToActionEffect(
                    action: { .updatedSelectedApplianceSuccess($0) },
                    failureAction: { .handleError($0.equatable) }
                )
            
        case .updatedSelectedApplianceSuccess(let selectedAppliance):
            state.isLoading = false

            if state.shouldIgnorePopToRoot {
                return .just(.report(.validated(selectedAppliance: selectedAppliance)))
            }
            return .just(.report(.popToRootView))
            
        case .userTappedDisplayKitchenware(let appliance, let kitchenwares):
            state.kitchenwareList = .initial(
                appliance: appliance,
                selectedKitchenwares: kitchenwares
            )
            
        case .displayCapacityPicker:
            if let defaultCapacity = state.chosenAppliance.capacities.first {
                state.capacitySelection = .initial(
                    configuration: .init(
                        capacities: state.chosenAppliance.capacities,
                        defaultCapacity: defaultCapacity
                    )
                )
            }
            
        case .saveNickname:
            break
            
        case .setNickName:
            break
            
        case .updateNickname(let nickname):
            state.applianceNickname = nickname
            
        case .handleError(let error):
            log.error("ApplianceDeclarationCore error: \(error)")
            state.isLoading = false
//            state.errorAlert = state.defaultErrorAlert
            
        case .dismissKitchenwareList:
            state.kitchenwareList = nil
            
        case .dismissAlert:
            break
//            state.errorAlert = nil
            
        case .dismissCapacitySelection:
            state.capacitySelection = nil
            
        case .capacitySelection(.report(let report)):
            switch report {
            case .userSelectedCapacity(let capacity):
                state.selectedCapacity = capacity
                return .just(.dismissCapacitySelection)
                
            case .userTappedCancel:
                return .just(.dismissCapacitySelection)
            }
            
        case .kitchenwareList(.report(let report)):
            switch report {
            case .finishedSelection(let kitchenwares):
                state.selectedKitchenwares = kitchenwares
                return .just(.dismissKitchenwareList)
            }
            
        case .kitchenwareList, .capacitySelection:
            break // handled by child
            
        case .report:
            break // handled by parent
        }
        return .none
    }
    .combined(with: analyticsMiddleware)
    .combined(with: kitchenwareListReducer)
    .combined(with: capacitySelectionReducer)
    }
    
    private static var capacitySelectionReducer: Self.Reducer { CapacitySelectionCore.reducer(
        state: \State.capacitySelection,
        action: /Action.capacitySelection,
        environment: { _ in .init() },
        dependencies: .none
    )}
    
    private static var kitchenwareListReducer: Self.Reducer { KitchenwareListCore<Cores>.reducer(
        state: \State.kitchenwareList,
        action: /Action.kitchenwareList,
        environment: { $0.kitchenwareList },
        dependencies: .none
    )}
}

///  ⚠️  This has no purpose in the TCA 1.x anymore as CoW is already applied to children in native TCA.
///
/// This wrapper should be applied on large structs to avoid stack overflows
/// https://github.com/pointfreeco/swift-composable-architecture/discussions/488
/// https://github.com/pointfreeco/swift-composable-architecture/discussions/752
///
/// CopyOnWrite explained a bit more here :
/// https://github.com/apple/swift/blob/main/docs/OptimizationTips.rst#advice-use-copy-on-write-semantics-for-large-values
///
/// We should avoid structs getting bigger memory size than 2000 bytes.
/// (crashes started to happen with 9000 bytes structs)
/// To get memory size of struct in bytes : MemoryLayout<MyRecipesCore.State>.size
///
@propertyWrapper
public struct CopyOnWrite<T> {
  private final class Reference {
    var val: T
    init(_ v: T) { val = v }
  }
  private var ref: Reference

  public init(wrappedValue: T) { ref = Reference(wrappedValue) }
  
  public var wrappedValue: T {
    get { ref.val }
    set {
      if !isKnownUniquelyReferenced(&ref) {
        ref = Reference(newValue)
        return
      }
      ref.val = newValue
    }
  }
}

// Restore automatic protocol conformance:
extension CopyOnWrite: Equatable where T: Equatable {
  public static func == (lhs: CopyOnWrite<T>, rhs: CopyOnWrite<T>) -> Bool {
    lhs.wrappedValue == rhs.wrappedValue
  }
}

extension CopyOnWrite: Hashable where T: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(wrappedValue)
  }
}

extension CopyOnWrite: Decodable where T: Decodable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let value = try container.decode(T.self)
    self = CopyOnWrite(wrappedValue: value)
  }
}

extension CopyOnWrite: Encodable where T: Encodable {
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(wrappedValue)
  }
}

/// The action dependencies of a TCACore.
/// The goal of this structure is to store the adaptation closure to be applied to the parent reducer in TCACore `reducer` method.
/// This way each TCACore can formalize its dependencies : Actions that need to come from parent aka descending (apply...) and actions that need to be handled by the parent aka ascending (report...)
///
/// Typically consists of applying a stream of resending calls to the parent reducer :
///
///
///      static func actionDependencies<GlobalState, GlobalAction, GlobalEnvironment>(
///         applyCounterUpdate: @escaping (Int) -> GlobalAction,
///         reportCounterUpdate: @escaping (Counter) -> GlobalAction,
///         reportBackToFeatureList: @escaping () -> GlobalAction
///     ) -> TCACoreActionDependencies<Action, GlobalState, GlobalAction, GlobalEnvironment> {
///         .init { reducer, fromLocalAction in
///             reducer
///             .resending(applyCounterUpdate, to: { fromLocalAction(.applyCounterUpdate($0)) })
///             .resending({ fromLocalAction(.reportCounterUpdate($0)) }, to: reportCounterUpdate)
///             .resending({ fromLocalAction(.reportBackToFeatureList) }, to: reportBackToFeatureList)
///         }
///     }
///
///

@available(iOS, deprecated: 100, message: "Just name actions `apply` & `report`. Dynamic configurations (shared state) should be passed via stateful service in environment (ex: authenticationService in Cookeat BaseEnvironment)")
public struct TCACoreActionDependencies<Action, GlobalState, GlobalAction, GlobalEnvironment> {
    
    public typealias ParentReducer = RxComposableArchitecture.Reducer<GlobalState, GlobalAction, GlobalEnvironment>
    public typealias Adaptation = (_ reducer: ParentReducer, _ fromLocalAction: @escaping (Action) -> GlobalAction) -> ParentReducer

    let adaptation: Adaptation
    
    /// Inits the Dependencies with the closure to adapt the reducer
    public init(_ adaptation: @escaping Adaptation) {
        self.adaptation = adaptation
    }
    
    /// The TCACore doesn't have dependencies.
    /// It will leave the reducer as is.
    public static var none: Self {
        .init { reducer, _ in reducer }
    }
}

extension TCACore {
    /// Transforms this Core's reducer into a reducer ready to be added to the `childReducers` array of the parent while specifying its dependencies.
    ///  This variant should only be used if the parent holds the state in a custom manner that requires a custom reducer transformation. (In most cases, the child state is stored as optional or as is so another variant of this method without `reducerTransform` can be used)
    ///
    /// - Parameters:
    ///   - reducerTransform: Transformation applied to reducer before pullback can occur. Typically `{ $0.optional }` for a state that is stored as optional in the parent
    ///   - toLocalState: A key path that can get/set State inside GlobalState.
    ///   - toLocalAction: A case path that can extract/embed Action from GlobalAction.
    ///   - toLocalEnvironment: A function that transforms GlobalEnvironment into Environment.
    ///   - dependencies: The dependencies of the child TCACore. Pass `.none` if the child doesn't have dependencies.
    /// - Returns: A pulled back reducer that can be directly used by the parent as a child reducer.
    public static func reducer<AlteredState, GlobalState, GlobalAction, GlobalEnvironment>(
        reducerTransform: (Reducer) -> RxComposableArchitecture.Reducer<AlteredState, Action, Environment>,
        state toLocalState: WritableKeyPath<GlobalState, AlteredState>,
        action toLocalAction: CasePath<GlobalAction, Action>,
        environment toLocalEnvironment: @escaping (GlobalEnvironment) -> Environment,
        dependencies: TCACoreActionDependencies<Action, GlobalState, GlobalAction, GlobalEnvironment>
    ) -> RxComposableArchitecture.Reducer<GlobalState, GlobalAction, GlobalEnvironment> {
            let parentReducer = reducerTransform(featureReducer)
                .pullback(state: toLocalState,
                          action: toLocalAction,
                          environment: toLocalEnvironment)
            return dependencies.adaptation(parentReducer, toLocalAction.embed)
    }
    
    /// Transforms this Core's reducer into a reducer ready to be added to the `childReducers` array of the parent while specifying its dependencies.
    ///  This variant can only be used if the parent holds the state as is.
    ///
    /// - Parameters:
    ///   - toLocalState: A key path that can get/set State inside GlobalState.
    ///   - toLocalAction: A case path that can extract/embed Action from GlobalAction.
    ///   - toLocalEnvironment: A function that transforms GlobalEnvironment into Environment.
    ///   - dependencies: The dependencies of the child TCACore. Pass `.none` if the child doesn't have dependencies.
    /// - Returns: A pulled back reducer that can be directly used by the parent as a child reducer.
    public static func reducer<GlobalState, GlobalAction, GlobalEnvironment>(
        state toLocalState: WritableKeyPath<GlobalState, State>,
        action toLocalAction: CasePath<GlobalAction, Action>,
        environment toLocalEnvironment: @escaping (GlobalEnvironment) -> Environment,
        dependencies: TCACoreActionDependencies<Action, GlobalState, GlobalAction, GlobalEnvironment>
    ) -> RxComposableArchitecture.Reducer<GlobalState, GlobalAction, GlobalEnvironment> {
        reducer(reducerTransform: { $0 },
                state: toLocalState,
                action: toLocalAction,
                environment: toLocalEnvironment,
                dependencies: dependencies)
    }
    
    /// Transforms this Core's reducer into a reducer ready to be added to the `childReducers` array of the parent while specifying its dependencies.
    /// This variant can only be used if the parent holds the state as optional.
    ///
    /// Ex: In the CounterListCore, we use this method to pullback the CounterCore reducer and use it as a child.
    ///
    ///
    ///     static var childReducers: [Self.Reducer] {
    ///          [CounterCore.reducer(
    ///             state: \State.displayedCounter,
    ///             action: /Action.counter,
    ///             environment: { _ in .init() },
    ///             dependencies: CounterCore.actionDependencies(
    ///                 applyCounterUpdate: { .updateDisplayedCounter($0) },
    ///                 reportCounterUpdate: { .counterUpdated($0) },
    ///                 reportBackToFeatureList: { .pop })
    ///          )]
    ///      }
    ///
    ///
    /// - Parameters:
    ///   - toLocalState: A key path that can get/set State inside GlobalState.
    ///   - toLocalAction: A case path that can extract/embed Action from GlobalAction.
    ///   - toLocalEnvironment: A function that transforms GlobalEnvironment into Environment.
    ///   - dependencies: The dependencies of the child TCACore. Pass `.none` if the child doesn't have dependencies.
    /// - Returns: A pulled back reducer that can be directly used by the parent as a child reducer.
    public static func reducer<GlobalState, GlobalAction, GlobalEnvironment>(
        state toLocalState: WritableKeyPath<GlobalState, State?>,
        action toLocalAction: CasePath<GlobalAction, Action>,
        environment toLocalEnvironment: @escaping (GlobalEnvironment) -> Environment,
        dependencies: TCACoreActionDependencies<Action, GlobalState, GlobalAction, GlobalEnvironment>
    ) -> RxComposableArchitecture.Reducer<GlobalState, GlobalAction, GlobalEnvironment> {
        reducer(reducerTransform: { $0.optional(breakpointOnNil: false) },
                state: toLocalState,
                action: toLocalAction,
                environment: toLocalEnvironment,
                dependencies: dependencies)
    }
}

/// Implemented by Environments that need to track analytics events.
@available(iOS, deprecated: 999, message: "TCA 1.x doesn't have environments anymore")
public protocol TrackedCoreEnvironment {

}

public extension ObservableType where Element == Void {
    /// Converts an old-school method with success & error closures to an observable stream.
    /// Returns the result (or error) & completes.
    /// ```
    /// Observable.from(userProductsService.getProducts)
    /// ```
    /// - Parameter successErrorClosure: The closure taking both a success & failure closure as
    /// parameter
    /// - Returns: An observable stream that publishes the result from success closure & completes
    /// or the error from error closure.
    static func from(
        _ successErrorClosure: @escaping (@escaping () -> Void, @escaping (Error) -> Void) -> Void
    ) -> Observable<Void> {
        from { (successClosure: @escaping (()) -> Void, failureClosure) in
            successErrorClosure({ successClosure(()) }, failureClosure)
        }
    }
    
    /// Converts an old-school method with success & error closures to an observable of `Result`.
    /// Returns the result & completes.
    /// ```
    /// Observable.resultFrom(userProductsService.getProducts)
    /// ```
    /// - Parameter successErrorClosure: The closure taking both a success & failure closure as
    /// parameter
    /// - Returns: An observable stream that publishes the result from success closure & completes
    /// or the error result from error closure & completes.
    static func resultFrom<Failure: Error>(
        _ successErrorClosure: @escaping (@escaping () -> Void, @escaping (Failure) -> Void) -> Void
    ) -> Observable<Result<Void, Failure>> {
        resultFrom { (successClosure: @escaping (()) -> Void, failureClosure) in
            successErrorClosure({ successClosure(()) }, failureClosure)
        }
    }
    
    /// Converts an old-school method with success & error closures to an observable stream.
    /// Returns the result (or error) & completes.
    /// ```
    /// Observable.from(newProduct, applying: self.productService.update)
    /// ```
    /// - Parameter arg1: The parameter of the closure
    /// - Parameter successErrorClosure: The closure taking both a success & failure closure as
    /// parameter
    /// - Returns: An observable stream that publishes the result from success closure & completes
    /// or the error from error closure.
    static func from<T>(
        _ arg1: T,
        applying successErrorClosure:
        @escaping (T, @escaping () -> Void, @escaping (Error) -> Void) -> Void
    ) -> Observable<Void> {
        from(arg1) { (arg, successClosure: @escaping (()) -> Void, failureClosure) in
            successErrorClosure(arg, { successClosure(()) }, failureClosure)
        }
    }
}

public extension ObservableType {
    /// Converts an old-school method with success & error closures to an observable stream.
    /// Returns the result (or error) & completes.
    /// ```
    /// Observable.from(userProductsService.getProducts)
    /// ```
    /// - Parameter successErrorClosure: The closure taking both a success & failure closure as
    /// parameter
    /// - Returns: An observable stream that publishes the result from success closure & completes
    /// or the error from error closure.
    static func from(
        _ successErrorClosure:
        @escaping (@escaping (Element) -> Void, @escaping (Error) -> Void) -> Void
    ) -> Observable<Element> {
        Observable.create { observer in
            successErrorClosure({ result in
                observer.onNext(result)
                observer.onCompleted()
            }, { error in
                observer.onError(error)
            })
            return Disposables.create()
        }
    }
    
    /// Converts an old-school method with success & error closures to an observable of `Result`.
    /// Returns the result & completes.
    /// ```
    /// Observable.resultFrom(userProductsService.getProducts)
    /// ```
    /// - Parameter successErrorClosure: The closure taking both a success & failure closure as
    /// parameter
    /// - Returns: An observable stream that publishes the result from success closure & completes
    /// or the error result from error closure & completes.
    static func resultFrom<Failure: Error>(
        _ successErrorClosure:
        @escaping (@escaping (Element) -> Void, @escaping (Failure) -> Void) -> Void
    ) -> Observable<Result<Element, Failure>> {
        Observable<Result<Element, Failure>>.create { observer in
            successErrorClosure({ element in
                observer.onNext(.success(element))
                observer.onCompleted()
            }, { error in
                observer.onNext(.failure(error))
                observer.onCompleted()
            })
            return Disposables.create()
        }
    }
    
    /// Converts an old-school method with success & error closures to an observable stream.
    /// Returns the result (or error) & completes.
    /// ```
    /// Observable.from(newProduct, applying: self.productService.update)
    /// ```
    /// - Parameter arg1: The parameter of the closure
    /// - Parameter successErrorClosure: The closure taking both a success & failure closure as
    /// parameter
    /// - Returns: An observable stream that publishes the result from success closure & completes
    /// or the error from error closure.
    static func from<T>(
        _ arg1: T,
        applying successErrorClosure:
        @escaping (T, @escaping (Element) -> Void, @escaping (Error) -> Void) -> Void
    ) -> Observable<Element> {
        Observable.create { observer in
            successErrorClosure(arg1, { element in
                observer.onNext(element)
                observer.onCompleted()
            }, { error in
                observer.onError(error)
            })
            return Disposables.create()
        }
    }
    
    /// Performs the opposite operation of `unwrap`
    /// Maps the observable of Element to an observable of Result of Element & generic Error
    func catchToResult() -> Observable<Result<Element, Error>> {
        map { Result.success($0) }
            .catch { Observable.just(.failure($0)) }
    }
    
    /// Performs the opposite operation of `catchToResult`
    /// by unwrapping the element from the result. Type of error will be lost in the process
    func unwrap<Unwrapped, Failure: Error>(
    ) -> Observable<Unwrapped> where Element == Result<Unwrapped, Failure> {
        map { try $0.get() }
    }
}

public extension PrimitiveSequence where Trait == SingleTrait {
    /// Performs the opposite operation of `catchToResult`
    /// by unwrapping the element from the result. Type of error will be lost in the process
    func unwrap<Unwrapped, Failure: Error>(
    ) -> Single<Unwrapped> where Element == Result<Unwrapped, Failure> {
        map { try $0.get() }
    }
    
    /// Performs the opposite operation of `unwrap`
    /// Maps the observable of Element to an observable of Result of Element & generic Error
    func catchToResult() -> Single<Result<Element, Error>> {
        map { Result.success($0) }
            .catch { Single.just(.failure($0)) }
    }
}

import Foundation

extension String {
    /// Define if a string match with provided regex.
    ///
    /// - Parameters:
    ///   - regex: Regex matches with string.
    ///   - options: Options of expression.
    /// - Returns: True if match.
    public func isMatch(_ regex: String, options: NSRegularExpression.Options? = [.caseInsensitive]) -> Bool {
        let exp = try? NSRegularExpression(pattern: regex, options: options ?? [])
        return exp?.firstMatch(in: self, options: [], range: NSRange(location: 0, length: utf16.count)) != nil
    }
    
    /// Remove spaces from a string.
    ///
    /// - Returns: String spaces removed
    public func removeWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
    
    /// True if this is not an empty string
    public var isNotEmpty: Bool { !isEmpty }
}

extension Array {
    /// Return an element at provided index.
    /// If the index exceed array bounds, it returns nil and not crash.
    ///
    /// - Parameter index: Element index.
    /// - Returns: Element if it found otherwise nil.
    public func atIndex(_ index: Int) -> Element? {
        guard index >= self.startIndex, index < self.endIndex else {
            return nil
        }
        
        return self[index]
    }
    
    /// - Get : return the element or nil if the index is invalid
    /// - Set : sets the element at the specified index or does nothing if index is invalid
    public subscript(safe index: Int) -> Element? {
        get {
            guard index >= 0, index < endIndex else {
                return nil
            }

            return self[index]
        }
        set {
            guard index >= 0, index < endIndex, let newValue = newValue else {
                return
            }
            self[index] = newValue
        }
    }
    
    /// True if this is not an empty array
    public var isNotEmpty: Bool { !isEmpty }
}
