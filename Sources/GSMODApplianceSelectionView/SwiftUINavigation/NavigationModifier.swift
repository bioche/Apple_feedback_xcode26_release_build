////
////  NavigationModifier.swift
////  
////
////  Created by Eric BLACHERE on 26/05/2022.
////
//
//import SwiftUI
//
//import RxComposableArchitecture
//
//import RxSwift
//
//
//enum NavigationMethod {
//    case push
//    case present(PresentingOptions)
//}
//
//struct NavigationModifier<DestinationView: View, NavigationState: Equatable, NavigationAction, DestinationState: Equatable, DestinationAction>: ViewModifier {
//    
//    class NavigationActivationHandler: ObservableObject {
//        
//        init(_ childStore: Store<DestinationState?, DestinationAction>) {
//            self.childStore = childStore // keep a reference to the store
//            childStore.driver.drive(onNext: { [weak self] state in
//                self?.stateNotNil = state != nil
//            })
//            .disposed(by: disposeBag)
//        }
//        
//        @Published
//        var navigationIsActive: Bool = false
//        
//        func viewDidAppear() {
//            // wait for 0.5s after appearance before activating any push.
//            // Prevents weird animation glitches when we want to present then immediately push
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
//                self?.didAppear = true
//            }
//        }
//        
//        private let childStore: Store<DestinationState?, DestinationAction>
//        
//        private var didAppear: Bool = false {
//            didSet { computeNavigationIsActive() }
//        }
//        private var stateNotNil: Bool = false {
//            didSet { computeNavigationIsActive() }
//        }
//        
//        private func computeNavigationIsActive() {
//            let newValue = didAppear ? stateNotNil : false
//            
//            // only propagate if a real change occurred.
//            // Otherwise on iOS 14.5, we get "auto-pop" if 2 pushings are called one after another
//            guard navigationIsActive != newValue else { return }
//            
//            navigationIsActive = newValue
//        }
//        
//        private let disposeBag = DisposeBag()
//    }
//    
//    let method: NavigationMethod
//    
//    let destination: (Store<DestinationState, DestinationAction>) -> DestinationView
//    let parentStore: Store<NavigationState, NavigationAction>
//    let toDestinationState: (NavigationState) -> DestinationState?
//    let fromDestinationAction: (DestinationAction) -> NavigationAction
//    let exitAction: NavigationAction
//    
//    // using explicit handler instead of onChange avoids programmatic pop not working
//    @StateObject var navigationActivationHandler: NavigationActivationHandler
//    
//    @EnvironmentObject var navigationEnvironment: GSNavigationEnvironment
//    
//    func body(content: Content) -> some View {
//        content
//            .onAppear(perform: navigationActivationHandler.viewDidAppear)
//            .background( // we perform presenting on background for now to prevent iOS 14 issue with consecutive .sheet()
//                navigationView()
//            )
//    }
//    
//    @ViewBuilder
//    private func navigationView() -> some View {
//        switch method {
//        case .push:
//            NavigationLink(
//                isActive: navigationBinding,
//                // we explicitely pass navigation env as NavigationLink won't propagate it
//                // (enableNavigation is often set on NavigationView content & not on NavigationView itself)
//                destination: { destinationView().environmentObject(navigationEnvironment) },
//                label: { EmptyView() }
//            )
//            .accessibilityHidden(true)
//        case .present(let options):
//            Color.clear.presenting(
//                isPresented: navigationBinding,
//                options: options,
//                content: {
//                    destinationView()
//                        .interactiveDismissDisabled(!options.interactiveDismiss)
//                        .environmentObject(GSNavigationEnvironment())
//                }
//            )
//            .onChange(of: navigationActivationHandler.navigationIsActive) { isPresenting in
//                navigationEnvironment.isPresenting = isPresenting
//            }
//        }
//    }
//    
//    private var navigationBinding: Binding<Bool> {
//        .init(
//            get: { navigationActivationHandler.navigationIsActive },
//            set: { _ in parentStore.send(exitAction) }
//        )
//    }
//    
//    private func destinationView() -> some View {
//        IfLetStore(
//            parentStore
//                .scope(state: toDestinationState)
//            // delayed avoids visual bug when popping described here
//            // https://forums.swift.org/t/programatic-dismiss-navigation-animation-based-on-state-binding/39275
//                .delayed(when: { $0 == nil }, by: .milliseconds(750))
//                .scope(state: { $0 }, action: fromDestinationAction),
//            then: destination,
//            else: { EmptyView() }
//        )
//    }
//}
//
//private extension View {
//
//    @ViewBuilder
//    func presenting<Content: View>(
//        isPresented: Binding<Bool>,
//        options: PresentingOptions,
//        content: @escaping () -> Content
//    ) -> some View {
//        
//        switch options.mode {
//        case .sheet:
//            self.sheet(isPresented: isPresented, content: content)
//        case .fullScreen:
//            self.fullScreenCover(isPresented: isPresented, content: content)
//        case .popover:
//            self.popover(isPresented: isPresented, content: content)
//        }
//    }
//}
