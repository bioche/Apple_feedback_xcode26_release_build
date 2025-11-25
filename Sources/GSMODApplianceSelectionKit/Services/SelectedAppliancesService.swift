//
//  SelectedAppliancesService.swift
//  GSMODApplianceSelectionKit
//
//  Created by Olivier Tavel on 25/06/2019.
//  Copyright © 2019 groupeseb. All rights reserved.
//

import Foundation




import RxSwift

public protocol SelectedAppliancesService {
    // MARK: - Selected Appliances
    
    /// Get all selected appliances by User
    ///
    /// - Returns: Observable of SelectedAppliance array
    func getSelectedAppliances() -> Observable<[SelectedAppliance]>
    
    /// Get all selected appliances by User for a specific domain
    ///
    /// - Parameter domain: Specific domain
    /// - Returns: Observable of SelectedAppliance array
    func getSelectedAppliances(for domain: RawDomain) -> Observable<[SelectedAppliance]>
    
    /// Get a specific selected appliance by User using a specific identifier
    ///
    /// - Parameter id: Specific identifier
    /// - Returns: Observable of SelectedAppliance
    func getSelectedAppliance(productId: ProductId) -> Observable<SelectedAppliance>
    
    /// Select an appliance and add to selected appliance by user
    ///
    /// - Parameters:
    ///   - id: Id of appliance selected by User
    ///   - capacity: Capacity for the selected appliance
    /// - Returns: An observable on the selected appliance built from the merge of `appliance` & the product given by user service. Nil if the client app chose not to create the product yet.
    @discardableResult
    func addSelectedAppliance(appliance: Appliance, capacity: Capacity?, kitchenwareIds: [KitchenwareId], nickname: String?) -> Observable<SelectedAppliance?>
    
    /// Update the selected appliance
    ///
    /// - Parameter selectedAppliance: Selected appliance to update
    func updateSelectedAppliance(_ selectedAppliance: SelectedAppliance) -> Observable<SelectedAppliance>
    
    /// Remove a selected appliance with his id
    ///
    /// - Parameter productId: Selected appliance id
    func removeSelectedAppliance(productId: ProductId) -> Observable<Void>
    
    /// Get the number of selected appliances
    ///
    /// - Returns: Observable Int number
    func numberOfSelectedAppliances() -> Observable<Int>
    
    /// Check if an update is available for a specified productId.
    ///
    /// - Parameter productId: Product id shoulb be checked
    func checkUpdateFirmare(productId: ProductId) -> Observable<Bool>
    
    /// Get selected kitchenwares from a productId
    ///
    /// - Parameter productId: Product id wherre kitchenwares should be retrived
    /// - Returns: Obsersable of kitchenwares array
    func getSelectedKitchenwares(productId: ProductId) -> Observable<[Kitchenware]>
    
    /// Erases persistent store of selected appliances.
    /// Also asks client app to invalidate its caches.
    /// This can be useful to make sure selected appliances are up-to-date with user profile on the next `getSelectedAppliances` call
    ///
    /// - Returns: Observable that emits once erasing is done
    /// - Parameter onlyProducts: Only the remote (client) cache should be invalidated. Persistent store will be left untouched
    func eraseSelectedAppliancesCache(onlyProducts: Bool) -> Observable<Void>
}
