//
//  CapacitySelectionCore.swift
//
//
//  Created by Samir Tiouajni on 02/06/2024.
//

import RxComposableArchitecture


import GSMODApplianceSelectionKit
import GSMODApplianceSelectionComposableInterfaces

public struct CapacitySelectionCore: TCACore {
    
    public struct Configuration: Equatable {
        public let capacities: [Capacity]
        public let defaultCapacity: Capacity
    }
    
    public struct State: Equatable {
        
        var capacities: [Capacity]
        var selectedCapacity: Capacity
        
        public static func initial(
            configuration: CapacitySelectionCore.Configuration
        ) -> Self {
            .init(
                capacities: configuration.capacities.sorted { $0.quantity < $1.quantity }, 
                selectedCapacity: configuration.defaultCapacity
            )
        }
    }
    
    public enum Report: Equatable {
        /// - cancel: Send when user cancel selection of capacity.
        case userTappedCancel
        /// - selectCapacity: Send when user select a capacity.
        case userSelectedCapacity(Capacity)
    }
    
    public enum Action: Equatable {
        case selectCapacity(Capacity)
        case report(Report)
    }
    
    public struct Environment {}
    
    public static let featureReducer = Reducer { state, action, _ in
        switch action {
        case .selectCapacity(let capacity):
            state.selectedCapacity = capacity
            
        case .report:
            break // handled by parent
        }
        return .none
    }
}
