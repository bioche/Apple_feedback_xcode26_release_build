//
//  NavigationItemCustomization.swift
//  
//
//  Created by Eric BLACHERE on 01/05/2022.
//

import SwiftUI


extension View {
    /// Allows customization of NavigationItem.
    /// Can be done on any navigation node
    /// - Parameter configure: Custom configuration of navigationItem
    /// - Returns: View with customized navigation bar
    func navigationItem(configure: @escaping (UINavigationItem) -> Void) -> some View {
        modifier(NavigationBarCustomizationViewModifier(configureNavigationItem: { navItem in
            configure(navItem)
        }))
    }
    
    /// ⚠️ This can cause glitches in navBar animation. To be avoided for now
    /// In theory could be used hand in hand with `navigationBar` counterpart
    /// to customize for specific screen.
    @MainActor
    func navigationItem(
        backgroundColor: KeyPath<ThemeProtocol, UIColor> = \.backgroundMainColor,
        tintColor: KeyPath<ThemeProtocol, UIColor> = \.contentMainColor,
        shadowColor: UIColor = .clear
    ) -> some View {
        navigationItem { navItem in
            navItem.editAllAppearances { appearance in
                appearance.backgroundColor = Theme.shared[keyPath: backgroundColor]
                appearance.shadowColor = shadowColor
                appearance.titleTextAttributes = [.foregroundColor: Theme.shared[keyPath: tintColor]]
            }
        }
    }

    /// Sets navigation title for current item in navigation stack.
    /// Even if hidden it will show on the navigation menu when long pressing back button
    func navigationTitle(
        _ title: String,
        hidden: Bool,
        backButtonDisplayMode: UINavigationItem.BackButtonDisplayMode = .minimal
    ) -> some View {
        navigationItem { navigationItem in
            if hidden {
                navigationItem.backButtonTitle = title
            } else {
                navigationItem.title = title
            }
            navigationItem.backButtonDisplayMode = backButtonDisplayMode
        }
    }
    
    /// Use this to display a custom title different from the navigation title used in stack
    func navigationTitle(
        _ title: String,
        displayedTitle: String,
        backButtonDisplayMode: UINavigationItem.BackButtonDisplayMode = .minimal,
        titleTintColor: Color? = nil
    ) -> some View {
        modifier(NavigationItemTitleModifier(
            title: title,
            displayedTitle: displayedTitle,
            backButtonDisplayMode: backButtonDisplayMode,
            titleTintColor: titleTintColor
        ))
    }
}

/// Captures navigation bar tint color to use it in toolbar
private struct NavigationItemTitleModifier: ViewModifier {
    
    let title: String
    let displayedTitle: String
    let backButtonDisplayMode: UINavigationItem.BackButtonDisplayMode
    let titleTintColor: Color?
    
    @State var existingColor: UIColor?
    
    var foregroundColor: Color? {
        if let titleTintColor {
            return titleTintColor
        } else {
            return existingColor.map { Color($0) }
        }
    }
    
    func body(content: Content) -> some View {
        content
            .navigationBar { navBar in
                existingColor = navBar.tintColor
            }
            .navigationItem { navigationItem in
                navigationItem.backButtonTitle = title
                navigationItem.backButtonDisplayMode = backButtonDisplayMode
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Text(displayedTitle)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(foregroundColor)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
    }
}

extension UINavigationItem {
    func editAllAppearances(_ configure: (UINavigationBarAppearance) -> Void) {
        standardAppearance = standardAppearance ?? {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            return appearance
        }()
        scrollEdgeAppearance = scrollEdgeAppearance ?? standardAppearance?.copy()
        compactAppearance = compactAppearance ?? standardAppearance?.copy()
        compactScrollEdgeAppearance = compactScrollEdgeAppearance ?? standardAppearance?.copy()
        
        let appearances = [standardAppearance, scrollEdgeAppearance, compactAppearance, compactScrollEdgeAppearance]
        appearances
            .compactMap { $0 }
            .forEach(configure)
    }
}
