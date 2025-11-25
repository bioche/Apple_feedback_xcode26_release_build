//
//  NavigationBarCustomization.swift
//  
//
//  Created by Eric BLACHERE on 16/02/2022.
//

import SwiftUI


extension View {
    
    /// Allows customization of NavigationBar.
    /// You should call this on the first node of a NavigationView.
    /// It can technically be done on any node but no animation will occur
    /// - Parameter configure: Custom configuration of navigationBar
    /// - Returns: View with customized navigation bar
    func navigationBar(configure: @escaping (UINavigationBar) -> Void) -> some View {
        modifier(NavigationBarCustomizationViewModifier(configure: configure))
    }
    
    /// Allows customization of NavigationBar.
    /// - Parameters:
    ///   - hidden: false by default. If true, navbar will not be shown and all other parameters will be ignored
    ///   - backgroundColor: Color of the background of bar amongst theme colors
    ///   - opacity: Adds an alpha component to the background color
    ///   - blurStyle: Blur applied to the bar
    ///   - tintColor: Color of title & buttons amongst theme colors
    ///   - shadowColor: Color of shadow between bar & content
    /// - Returns: View with customized navigation bar
    @ViewBuilder
    @MainActor func navigationBar(
        hidden: Bool = false,
        backgroundColor: KeyPath<ThemeProtocol, UIColor> = \.backgroundMainColor,
        opacity: CGFloat = 1,
        blurStyle: UIBlurEffect.Style? = nil,
        tintColor: KeyPath<ThemeProtocol, UIColor> = \.contentMainColor,
        shadowColor: UIColor = .clear
    ) -> some View {
        if hidden {
            self.navigationBarHidden(true)
        } else {
            _navigationBar(
                backgroundColor: Theme.shared[keyPath: backgroundColor],
                opacity: opacity,
                blurStyle: blurStyle,
                tintColor: Theme.shared[keyPath: tintColor],
                shadowColor: shadowColor
            )
            .navigationBarHidden(false)
        }
    }
    
    /// ⚠️ Only use for debug purposes ;)
    /// - Parameters:
    ///   - backgroundColor: Color of the background of bar
    ///   - opacity: Adds an alpha component to the background color
    ///   - blurStyle: Blur applied to the bar
    ///   - tintColor: Color of title & buttons
    ///   - shadowColor: Color of shadow between bar & content
    /// - Returns: View with customized navigation bar
    @MainActor
    func _navigationBar(
        backgroundColor: UIColor,
        opacity: CGFloat = 1,
        blurStyle: UIBlurEffect.Style? = nil,
        tintColor: UIColor,
        shadowColor: UIColor = .clear
    ) -> some View {
        navigationBar { navigationBar in
            navigationBar.editAllAppearances { appearance in
                appearance.backgroundColor = backgroundColor
                    .withAlphaComponent(opacity)
                appearance.shadowColor = shadowColor
                appearance.titleTextAttributes = [.foregroundColor: tintColor]
                appearance.largeTitleTextAttributes = [.foregroundColor: tintColor]
                
                if let blurStyle = blurStyle {
                    appearance.backgroundEffect = UIBlurEffect(style: blurStyle)
                } else {
                    appearance.backgroundEffect = nil
                }

                // avoid back button color glitches when popping when using tintColor
                let image = UIImage(systemName: "chevron.backward")?
                    .withTintColor(tintColor, renderingMode: .alwaysOriginal)
                appearance.setBackIndicatorImage(image, transitionMaskImage: image)
            }
        }
    }
    
    /// Changes back button title color to clear.
    /// This should not be necessary if `backButtonDisplayMode` was set to minimal
    /// via `navigationTitle` method
    @MainActor
    func barBackButtonHidden(_ hidden: Bool) -> some View {
        navigationBar {
            $0.editAllAppearances { appearance in
                if hidden {
                    appearance.backButtonAppearance.normal.titleTextAttributes = [
                        .foregroundColor: UIColor.clear
                    ]
                } else {
                    appearance.backButtonAppearance = appearance.buttonAppearance.copy()
                }
            }
        }
    }
}

extension UINavigationBar {
    func editAllAppearances(_ configure: (UINavigationBarAppearance) -> Void) {
        scrollEdgeAppearance = scrollEdgeAppearance ?? standardAppearance.copy()
        compactAppearance = compactAppearance ?? standardAppearance.copy()
        compactScrollEdgeAppearance = compactScrollEdgeAppearance ?? standardAppearance.copy()
        
        let appearances = [standardAppearance, scrollEdgeAppearance, compactAppearance, compactScrollEdgeAppearance]
        appearances
            .compactMap { $0 }
            .forEach(configure)
    }
}

struct NavigationBarCustomizationViewModifier: ViewModifier {
    
    var configure: (UINavigationBar) -> Void = { _ in }
    var configureNavigationItem: (UINavigationItem) -> Void = { _ in }

    func body(content: Content) -> some View {
        content.background(NavigationBarCustomizer(configure: configure, configureNavigationItem: configureNavigationItem))
    }
}

struct NavigationBarCustomizer: UIViewControllerRepresentable {
    let configure: (UINavigationBar) -> Void
    let configureNavigationItem: (UINavigationItem) -> Void
    
    func makeUIViewController(
        context: UIViewControllerRepresentableContext<NavigationBarCustomizer>
    ) -> NavigationBarCustomizationViewController {
        .init(configure: configure, configureNavigationItem: configureNavigationItem)
    }

    func updateUIViewController(
        _ uiViewController: NavigationBarCustomizationViewController,
        context: UIViewControllerRepresentableContext<NavigationBarCustomizer>
    ) {
        uiViewController.update(configure: configure, configureNavigationItem: configureNavigationItem)
    }
}

final class NavigationBarCustomizationViewController: UIViewController {
    var configure: (UINavigationBar) -> Void
    var configureNavigationItem: (UINavigationItem) -> Void

    init(
        configure: @escaping (UINavigationBar) -> Void,
        configureNavigationItem: @escaping (UINavigationItem) -> Void
    ) {
        self.configure = configure
        self.configureNavigationItem = configureNavigationItem
        super.init(nibName: nil, bundle: nil)
    }
    
    func update(
        configure: @escaping (UINavigationBar) -> Void,
        configureNavigationItem: @escaping (UINavigationItem) -> Void
    ) {
        self.configure = configure
        self.configureNavigationItem = configureNavigationItem
        applyConfigurations()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // applying configuration both in will & did appear to avoid navigationBar reverting
    // to global appearance when switching tabs. ViewWillAppear should suffice once we
    // delete the global appearance application in Theme.applyAppearance
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        applyConfigurations()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        applyConfigurations()
    }
    
    private func applyConfigurations() {
        if let navigationController = navigationController {
            configure(navigationController.navigationBar)
        }
        configureNavigationItem(navigationItem)
        if let navigationItem = parent?.navigationItem {
            configureNavigationItem(navigationItem)
        }
    }
}
