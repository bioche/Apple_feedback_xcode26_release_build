//
//  SelectedAppliancesPersistentStore.swift
//  GSMODApplianceSelectionKit
//
//  Created by Olivier Tavel on 12/08/2019.
//  Copyright © 2019 groupeseb. All rights reserved.
//

import Foundation



import Realm
import RealmSwift
import RxSwift

public struct SelectedAppliancesPersistentStore {
    private let realmInstanceProvider: RealmInstanceProvidingService
    public var realmInstance: Realm {
        do {
            return try realmInstanceProvider.realmInstance()
        } catch {
            fatalError("could not get an instance of realm: \(error)")
        }
    }
    
    public init(realmInstanceProvider: RealmInstanceProvidingService) {
        self.realmInstanceProvider = realmInstanceProvider
    }
    
    func getAllSelectedAppliances(appliancesService: AppliancesService) -> Observable<[SelectedAppliance]> {
        let result = realmInstance.objects(SelectedApplianceRealm.self)
        let selectedAppliancesRealm = Array(result)
        
        return Observable.from(selectedAppliancesRealm) // Emet an observable for result of Realm request
            .toSelectedAppliance(appliancesService: appliancesService, store: self)
            .toArray()
            .map { $0.sorted() } // Sorted array by ApplianceId
            .asObservable()
    }
    
    func getSelectedAppliance(productId: ProductId, appliancesService: AppliancesService) -> Observable<SelectedAppliance> {
        guard let selectedApplianceRealm = realmInstance.objects(SelectedApplianceRealm.self).first(where: { $0.productId == productId }) else {
            return Observable.error(SelectedApplianceError.productNotFound(productId: productId))
        }
        
        return Observable.just(selectedApplianceRealm)
            .toSelectedAppliance(appliancesService: appliancesService, store: self)
    }
    
    /// Replace all selected appliances by new ones.
    ///
    /// - Parameter selectedAppliances: Selected appliances to be added.
    /// - Returns: ProductId of added selected appliances
    @discardableResult
    func replaceSelectedAppliancesBy(_ selectedAppliances: [SelectedAppliance]) -> [ProductId] {
        var selectedAppliancesRealm: [SelectedApplianceRealm] = []
        
        for selectedAppliance in selectedAppliances {
            let realmObject = SelectedApplianceRealm(from: selectedAppliance)
            selectedAppliancesRealm.append(realmObject)
        }
        
        do {
            try realmInstance.write {
                self.realmInstance.deleteAll()
                self.realmInstance.add(selectedAppliancesRealm, update: .all)
            }
        } catch let error {
            log.error("Failed to create selected appliance with error \(error.localizedDescription)")
        }
        
        return selectedAppliancesRealm.map { $0.productId }
    }
    
    @discardableResult
    func saveSelectedAppliance(// swiftlint:disable:this function_parameter_count
        applianceId: ApplianceId,
        productId: ProductId?,
        capacity: Capacity?,
        firmwareVersion: String?,
        nickname: String?,
        kitchenwares: [KitchenwareId] = [],
        iotSerialId: String?,
        source: String?,
        creationDate: Date? = Date(),
        modificationDate: Date? = Date()
    ) -> ProductId {
        let realmObject = SelectedApplianceRealm(
            applianceId: applianceId,
            productId: productId,
            firmwareVersion: firmwareVersion,
            nickname: nickname,
            capacity: capacity,
            kitchenwares: kitchenwares,
            iotSerialId: iotSerialId,
            source: source,
            creationDate: creationDate,
            modificationDate: modificationDate
        )
        
        do {
            try self.realmInstance.write {
                self.realmInstance.add(realmObject, update: .all)
            }
        } catch let error {
            log.error("Failed to create selected appliance with error \(error.localizedDescription)")
        }
        
        return String(realmObject.productId)
    }
    
    func updateSelectedAppliance(_ selectedAppliance: SelectedAppliance) {
        let realmObject = SelectedApplianceRealm(from: selectedAppliance)
            
        do {
            try self.realmInstance.write {
                realmInstance.add(realmObject, update: .all)
            }
        } catch let error {
            log.error("Failed to update selected appliance with error \(error.localizedDescription)")
        }
    }
    
    func removeSelectedAppliance(productId: String) {
        guard let selectedAppliance = realmInstance.object(ofType: SelectedApplianceRealm.self, forPrimaryKey: productId) else { return }
        
        do {
            try realmInstance.write {
                realmInstance.delete(selectedAppliance, cascading: true)
            }
        } catch let error {
            log.error("Failed to delete selected appliance with error \(error.localizedDescription)")
        }
    }
    
    func deleteAll() {
        do {
            try realmInstance.write {
                realmInstance.deleteAll()
            }
        } catch let error {
            log.error("error when delete all appliances cache : \(error)")
        }
    }
    
    func invalidate() {
        deleteAll()
    }
}
