////
////  View+presenting.swift
////  
////
////  Created by Eric BLACHERE on 17/01/2022.
////
//
//import Foundation
//import SwiftUI
//
//import RxComposableArchitecture
//
//
//struct PresentingOptions {
//    enum Mode {
//        case sheet
//        case fullScreen
//        case popover
//    }
//    
//    /// Presentation mode : gives the container shape for the modal
//    let mode: Mode
//    /// If disabled user can't dismiss using drag gesture
//    let interactiveDismiss: Bool
//    
//    init(
//        mode: Mode = .sheet,
//        interactiveDismiss: Bool = true
//    ) {
//        self.mode = mode
//        self.interactiveDismiss = interactiveDismiss
//    }
//}
//
//extension View {
//    @MainActor
//    func presenting<
//        DestinationView: View, NavigationState: Equatable,
//        NavigationAction, DestinationState: Equatable,
//        DestinationAction
//    >(
//        destination: @escaping (Store<DestinationState, DestinationAction>) -> DestinationView,
//        parentStore: Store<NavigationState, NavigationAction>,
//        state toDestinationState: @escaping (NavigationState) -> DestinationState?,
//        action fromDestinationAction: @escaping (DestinationAction) -> NavigationAction,
//        exitAction: NavigationAction,
//        options: PresentingOptions = .init()
//    ) -> some View {
//        modifier(
//            NavigationModifier(
//                method: .present(options),
//                destination: destination,
//                parentStore: parentStore,
//                toDestinationState: toDestinationState,
//                fromDestinationAction: fromDestinationAction,
//                exitAction: exitAction,
//                navigationActivationHandler: .init(
//                    parentStore.scope(state: toDestinationState, action: fromDestinationAction)
//                )
//            )
//        )
//    }
//    
//    @MainActor
//    func presenting<
//        DestinationView: View, NavigationState: Equatable,
//        NavigationAction, DestinationState: Equatable
//    >(
//        destinationFromState: @escaping (DestinationState) -> DestinationView,
//        parentStore: Store<NavigationState, NavigationAction>,
//        state toDestinationState: @escaping (NavigationState) -> DestinationState?,
//        exitAction: NavigationAction,
//        options: PresentingOptions = .init()
//    ) -> some View {
//        self.presenting(
//            destination: { store in destinationFromState(store.state) },
//            parentStore: parentStore,
//            state: toDestinationState,
//            action: { $0 },
//            exitAction: exitAction,
//            options: options
//        )
//    }
//    
//    @MainActor
//    func presenting<
//        DestinationView: View, NavigationState: Equatable,
//        NavigationAction
//    >(
//        staticDestination: @escaping () -> DestinationView,
//        parentStore: Store<NavigationState, NavigationAction>,
//        isDisplayed: @escaping (NavigationState) -> Bool,
//        exitAction: NavigationAction,
//        options: PresentingOptions = .init()
//    ) -> some View {
//        self.presenting(
//            destination: { _ in staticDestination() },
//            parentStore: parentStore,
//            state: { isDisplayed($0) ? NoContent() : nil },
//            action: { $0 },
//            exitAction: exitAction,
//            options: options
//        )
//    }
//}
