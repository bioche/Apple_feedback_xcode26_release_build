//
//  OnPauseResumeModifiers.swift
//  
//
//  Created by Eric BLACHERE on 19/11/2022.
//

import SwiftUI



struct OnResumeModifier: ViewModifier {
    
    let closure: () -> Void
    let onAppForeground: Bool
    
    @State var onScreen: Bool = false
    
    @EnvironmentObject var navigationEnvironment: GSNavigationEnvironment
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                closure()
                onScreen = true
            }
            .onDisappear { onScreen = false }
            .onChange(of: navigationEnvironment.isPresenting) { newIsPresenting in
                if !newIsPresenting { closure() }
                onScreen = !newIsPresenting
            }
            .onReceive(NotificationCenter.default.publisher(
                for: UIApplication.didBecomeActiveNotification)
            ) { _ in
                guard onAppForeground && onScreen else { return }
                closure()
            }
    }
}

extension View {
    /// To be used an a replacement of `onAppear` in SwiftUI views.
    /// Called in same cases as `onAppear`
    /// + when a presented modal above this view gets dismissed (only if Navigation modifier `.presenting` is used)
    /// + when scene becomes active (app comes in foreground) if `onAppForeground` is true
    /// ⚠️ `enableNavigation` needs to be called somewhere above in the View hierarchy otherwise it will crash 💥
    /// - Parameter closure: Closure that will perform refreshing
    /// Typically we will send `onAppear` action to the store here
    @MainActor
    public func onResume(perform closure: @escaping () -> Void, onAppForeground: Bool = true) -> some View {
        self.modifier(OnResumeModifier(closure: closure, onAppForeground: onAppForeground))
    }
}

struct OnPauseModifier: ViewModifier {
    
    let closure: () -> Void
    let onAppBackground: Bool
    
    @State var onScreen: Bool = false
    
    @EnvironmentObject var navigationEnvironment: GSNavigationEnvironment
    
    func body(content: Content) -> some View {
        content
            .onAppear { onScreen = true }
            .onDisappear {
                closure()
                onScreen = false
            }
            .onChange(of: navigationEnvironment.isPresenting) { newIsPresenting in
                if newIsPresenting { closure() }
                onScreen = !newIsPresenting
            }
            .onReceive(NotificationCenter.default.publisher(
                for: UIApplication.willResignActiveNotification
            )) { _ in
                guard onAppBackground && onScreen else { return }
                closure()
            }
    }
}

extension View {
    /// To be used an a replacement of `onDisappear` in SwiftUI views.
    /// Called in same cases as `onDisappear`
    /// + when a modal gets presented above this view (only if Navigation modifier `.presenting` is used)
    /// + when scene becomes inactive (app goes to background) if `onAppBackground` is true
    /// ⚠️ `enableNavigation` needs to be called somewhere above in the View hierarchy otherwise it will crash 💥
    /// - Parameter closure: Called when screen gets covered. Could cancel some listening here
    /// Typically we will send action `onDisappear` to the store here to do some cleaning
    @MainActor
    public func onPause(perform closure: @escaping () -> Void, onAppBackground: Bool = true) -> some View {
        self.modifier(OnPauseModifier(closure: closure, onAppBackground: onAppBackground))
    }
}
