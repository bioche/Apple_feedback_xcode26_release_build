//
//  View+pushing.swift
//  
//
//  Created by Bioche on 31/12/2021.
//  
//

import SwiftUI
import RxComposableArchitecture

import GSMODCore

extension View {
    
    @MainActor
    func pushing<DestinationView: View, NavigationState: Equatable, NavigationAction, DestinationState: Equatable, DestinationAction>(
        destination: @escaping (Store<DestinationState, DestinationAction>) -> DestinationView,
        parentStore: Store<NavigationState, NavigationAction>,
        state toDestinationState: @escaping (NavigationState) -> DestinationState?,
        action fromDestinationAction: @escaping (DestinationAction) -> NavigationAction,
        exitAction: NavigationAction
    ) -> some View {
        modifier(
            NavigationModifier(
                method: .push,
                destination: destination,
                parentStore: parentStore,
                toDestinationState: toDestinationState,
                fromDestinationAction: fromDestinationAction,
                exitAction: exitAction,
                navigationActivationHandler: .init(
                    parentStore.scope(state: toDestinationState, action: fromDestinationAction)
                )
            )
        )
    }
    
    @MainActor
    func pushing<DestinationView: View, NavigationState: Equatable, NavigationAction, DestinationState: Equatable>(
        destinationFromState: @escaping (DestinationState) -> DestinationView,
        parentStore: Store<NavigationState, NavigationAction>,
        state toDestinationState: @escaping (NavigationState) -> DestinationState?,
        exitAction: NavigationAction
    ) -> some View {
        self.pushing(
            destination: { store in destinationFromState(store.state) },
            parentStore: parentStore,
            state: toDestinationState,
            action: { $0 },
            exitAction: exitAction
        )
    }
    
    @MainActor
    func pushing<DestinationView: View, NavigationState: Equatable, NavigationAction, DestinationState: Equatable>(
        staticDestination: @escaping () -> DestinationView,
        parentStore: Store<NavigationState, NavigationAction>,
        isDisplayed: @escaping (NavigationState) -> Bool,
        exitAction: NavigationAction
    ) -> some View {
        self.pushing(
            destination: { _ in staticDestination() },
            parentStore: parentStore,
            state: { isDisplayed($0) ? NoContent() : nil },
            action: { $0 },
            exitAction: exitAction
        )
    }
}
