//
//  GSMODApplianceSelectionExampleApp.swift
//  GSMODApplianceSelectionExample
//
//  Created by Samir Tiouajni on 05/06/2024.
//

import SwiftUI

import GSMODApplianceSelectionKit
import GSMODApplianceSelectionView

import Swinject
import SwiftyBeaver
import GSMODWebClient


import GSMODCore

@main
struct GSMODApplianceSelectionExampleApp: App {
    
    let applianceDomainConfigurations: [RawDomain: ApplianceDomainConfiguration] =
    ["PRO_ACT": ApplianceDomainConfiguration(name: "Actifry", iconName: "ic_recipe_actifry", order: 2),
     "PRO_KIT": ApplianceDomainConfiguration(name: "Kitchen Coach", iconName: "ic_recipe_kitchencoach", order: 3),
     "PRO_AUT": ApplianceDomainConfiguration(name: "Smart&Tasty", iconName: "ic_recipe_autocuiseur", order: 4),
     "PRO_CAK": ApplianceDomainConfiguration(name: "Cake Factory", iconName: "ic_recipe_cakefactory", order: 5),
     "PRO_COO": ApplianceDomainConfiguration(name: "Cookeo", iconName: "ic_recipe_cookeo", order: 1),
     "PRO_COM": ApplianceDomainConfiguration(name: "Companion", iconName: "ic_recipe_companion", order: 0),
     "PRO_COP": ApplianceDomainConfiguration(name: "Cooking Connect", iconName: "ic_recipe_cookingconnect", order: nil),
     "PRO_OPG": ApplianceDomainConfiguration(name: "Optigrill", iconName: "ic_recipe_optigrill", order: nil),
     "PRO_STE": ApplianceDomainConfiguration(name: "Steam Up", iconName: "ic_recipe_steamup", order: nil),
     "PRO_SOC": ApplianceDomainConfiguration(name: "Soup&Co", iconName: nil, order: 10)
    ]
    
    init() {
        
        SwiftyBeaver.addDestination(ConsoleDestination())
        
        GSAppInfo.register(appInfo: .init(
            developerProgram: .exampleApp,
            appId: "GSMODApplianceSelectionExampleApp"
        ))
        
        Container.eventManager.register(GSEventManager.self) { (_) -> GSEventManager in
            return MockEventManager()
        }.inObjectScope(.container)
        
        DCPConfiguration.register(customConfiguration: DCPConfiguration(
            apiKey: "tLQ6PasWAb4didcWJT6ufYybl4IJh54p",
            baseURL: "https://sebplatform.api.groupe-seb.com",
            domainKey: "",
            environmentKey: ""
        ))
        
        Theme.applyApperance(.cookeat)
        
        let fileManager = FileManager.default
        let myDocuments = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        print(myDocuments.path)
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                SampleFlowView(
                    store: .init(
                        initialState: .initial(
                            applianceDomainConfigurations: applianceDomainConfigurations
                        ),
                        reducer: SampleCore.featureReducer,
                        environment: .live()
                    )
                )
                .navigationBar()
            }.navigationViewStyle(.stack)
            .enableNavigation()
        }
    }
}
