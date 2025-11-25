//
//  MigrationStoreRepository.swift
//  GSMODApplianceSelectionKit
//
//  Created by sebastien lablanchy on 28/01/2020.
//  Copyright © 2020 groupeseb. All rights reserved.
//

import Foundation

import RxSwift

/// Allows to request creation of local SelectedAppliances not present in DCP
/// ex: used in Cookeat when a user login and haven't product in DCP, Local store temporarily becomes the source of the truth
struct MigrationStoreRepository: MigrationStoreService {
    let selectedAppliancesPersistentStore: SelectedAppliancesPersistentStore
    let appliancesService: AppliancesService
    let userProductsService: UserProductsService
    let selectedAppliancesService: SelectedAppliancesService
    
    init(
        persistentStore: SelectedAppliancesPersistentStore,
        appliancesService: AppliancesService,
        userProductsService: UserProductsService,
        selectedAppliancesService: SelectedAppliancesService
    ) {
        self.selectedAppliancesPersistentStore = persistentStore
        self.appliancesService = appliancesService
        self.userProductsService = userProductsService
        self.selectedAppliancesService = selectedAppliancesService
    }
    
    /// Allows to request creation of local SelectedAppliances not present in DCP
    func requestProductsCreationFromLocalStore() -> Observable<[UserProduct]> {
        return userProductsService
            .allUserProducts() // get all user product
            .toSelectedAppliances(appliancesService: appliancesService, selectedAppliancesService: selectedAppliancesService) // transform UserProducts to selectedAppliances
            .filterLocalSelectedAppliancesNotPresentInUser(appliancesService: appliancesService, localSelectedAppliancesPersistentStore: selectedAppliancesPersistentStore) // get only selectedAppliances not present in user
            .requestProductsCreation(userProductsService: userProductsService) // request products creation
    }
}

extension ObservableType where Element == [SelectedAppliance] {
    func filterLocalSelectedAppliancesNotPresentInUser(appliancesService: AppliancesService, localSelectedAppliancesPersistentStore: SelectedAppliancesPersistentStore) -> Observable<[SelectedAppliance]> {
        return self
            .flatMap({ userSelectedAppliances -> Observable<([SelectedAppliance], [SelectedAppliance])> in
                let observableUserSelectedAppliances = Observable.just(userSelectedAppliances)
                let observableLocalSelectedAppliances = localSelectedAppliancesPersistentStore
                           .getAllSelectedAppliances(appliancesService: appliancesService)
                           
                return Observable.zip(observableUserSelectedAppliances, observableLocalSelectedAppliances)
            })
            .flatMap({ (userSelectedAppliances, localSelectedAppliances) -> Observable<([SelectedAppliance], [SelectedAppliance])> in
                /// Filter not already in user
                let observableUserSelectedAppliances = Observable.just(userSelectedAppliances)
                let difference = localSelectedAppliances.filter({ !userSelectedAppliances.contains($0) })
                return Observable.zip(observableUserSelectedAppliances, Observable.from(optional: difference))
            })
            .flatMap({ (userSelectedAppliances, localSelectedAppliancesNotInUser) -> Observable<SelectedAppliance> in
                /// Filter not same domain that a other user appliance
                let appliancesNotInSameDomain = localSelectedAppliancesNotInUser.filter({ appliancesNotInUser in
                    return !userSelectedAppliances.contains(where: { selectedAppliance -> Bool in
                        return selectedAppliance.rawDomain == appliancesNotInUser.rawDomain
                    })
                })
                return Observable.from(appliancesNotInSameDomain)
            })
            .compactMap({ $0 })
            .toArray()
            .asObservable()
    }
}

extension ObservableType where Element == [SelectedAppliance] {
    func requestProductsCreation(userProductsService: UserProductsService) -> Observable<[UserProduct]> {
         return self
        .flatMapLatest { Observable.from($0) }
        .flatMap { selectedAppliance -> Observable<ProductCreationOutcome> in
            userProductsService.requestProductCreation(selectedAppliance.appliance, kitchenware: selectedAppliance.selectedKitchenware, capacity: selectedAppliance.selectedCapacity, nickname: selectedAppliance.nickname)
        }
        .map({ productCreationOutcome -> UserProduct? in
            guard let product = productCreationOutcome.product else {
                log.error("The client app chose not to create the product on selection")
                return nil
            }
            return product
        })
        .compactMap({ $0 })
        .toArray()
        .asObservable()
    }
}
