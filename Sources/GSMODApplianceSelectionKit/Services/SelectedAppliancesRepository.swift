//
//  SelectedAppliancesRepository.swift
//  GSMODApplianceSelectionKit
//
//  Created by Olivier Tavel on 10/07/2019.
//  Copyright © 2019 groupeseb. All rights reserved.
//

import Foundation



import RxSwift

struct SelectedAppliancesRepository: SelectedAppliancesService {    
    let selectedAppliancesPersistentStore: SelectedAppliancesPersistentStore
    let appliancesService: AppliancesService
    let kitchenwaresService: KitchenwaresService
    let userProductsService: UserProductsService
    
    init(persistentStore: SelectedAppliancesPersistentStore,
         appliancesService: AppliancesService,
         kitchenwaresService: KitchenwaresService,
         userProductsService: UserProductsService) {
        self.selectedAppliancesPersistentStore = persistentStore
        self.appliancesService = appliancesService
        self.kitchenwaresService = kitchenwaresService
        self.userProductsService = userProductsService
    }
    
    func getSelectedAppliances() -> Observable<[SelectedAppliance]> {
        return userProductsService
            .allUserProducts()
            .flatMapLatest { (userProducts) -> Observable<UserProduct> in
                return Observable.from(userProducts)
            }
            .toSelectedAppliance(appliancesService: appliancesService, selectedAppliancesService: self)
            .toArray()
            .asObservable()
            .do(onNext: { (selectedAppliances) in
                self.selectedAppliancesPersistentStore.replaceSelectedAppliancesBy(selectedAppliances)
            })
            .catch { (_) -> Observable<[SelectedAppliance]> in
                return self.selectedAppliancesPersistentStore
                    .getAllSelectedAppliances(appliancesService: self.appliancesService)
            }
    }
    
    func getSelectedAppliances(for domain: RawDomain) -> Observable<[SelectedAppliance]> {
        return getSelectedAppliances()
            .map({ selectedAppliances in
                selectedAppliances.filter { $0.rawDomain == domain }
            })
    }
    
    func getSelectedAppliance(productId: String) -> Observable<SelectedAppliance> {
        return userProductsService
            .userProduct(productId: productId)
            .toSelectedAppliance(appliancesService: appliancesService, selectedAppliancesService: self)
            .asObservable()
            .catch { (_) -> Observable<SelectedAppliance> in
                self.selectedAppliancesPersistentStore
                    .getSelectedAppliance(productId: productId, appliancesService: self.appliancesService)
            }
    }
    
    func addSelectedAppliance(appliance: Appliance, capacity: Capacity?, kitchenwareIds: [KitchenwareId] = [], nickname: String? = nil) -> Observable<SelectedAppliance?> {
        userProductsService
            .requestProductCreation(appliance, kitchenware: kitchenwareIds, capacity: capacity, nickname: nickname)
            .map { outcome in
                guard let product = outcome.product else {
                    GSMODApplianceSelectionKit.log.info("The client app chose not to create the product on selection")
                    return nil
                }
                self.selectedAppliancesPersistentStore
                    .saveSelectedAppliance(
                        applianceId: appliance.applianceId,
                        productId: product.productId,
                        capacity: capacity,
                        firmwareVersion: product.firmwareVersion,
                        nickname: product.nickname,
                        kitchenwares: kitchenwareIds,
                        iotSerialId: product.iotSerialId,
                        source: product.source
                    )
                return SelectedAppliance(
                    appliance: appliance,
                    productId: product.productId,
                    firmwareVersion: product.firmwareVersion,
                    nickname: product.nickname,
                    capacity: capacity,
                    kitchenwares: kitchenwareIds,
                    iotSerialId: product.iotSerialId,
                    source: product.source,
                    creationDate: product.creationDate,
                    modificationDate: product.modificationDate
                )
            }
    }
    
    func updateSelectedAppliance(_ selectedAppliance: SelectedAppliance) -> Observable<SelectedAppliance> {
        let userProduct = selectedAppliance.toUserProduct()
        return userProductsService
            .updateProduct(userProduct)
            .map({ _ in
                self.selectedAppliancesPersistentStore.updateSelectedAppliance(selectedAppliance)
                return selectedAppliance
            })
    }
    
    func removeSelectedAppliance(productId: ProductId) -> Observable<Void> {
        return userProductsService
            .removeProduct(productId)
            .map({ _ in
                self.selectedAppliancesPersistentStore.removeSelectedAppliance(productId: productId)
                return
            })
    }
    
    func numberOfSelectedAppliances() -> Observable<Int> {
        return getSelectedAppliances()
            .map { $0.count }
    }
    
    func checkUpdateFirmare(productId: ProductId) -> Observable<Bool> {
        return userProductsService
            .checkUpdateFirmware(productId: productId)
    }
    
    func getSelectedKitchenwares(productId: ProductId) -> Observable<[Kitchenware]> {
        return getSelectedAppliance(productId: productId)
            .retrieveKitchenwares(kitchenwaresService: kitchenwaresService)
            .map { (selectedAppliance, kitchenwares) in
                kitchenwares.filter { selectedAppliance.selectedKitchenware.contains($0.key) }
            }
    }
    
    func eraseSelectedAppliancesCache(onlyProducts: Bool) -> Observable<Void> {
        if !onlyProducts {
            selectedAppliancesPersistentStore.replaceSelectedAppliancesBy([])
        }
        return userProductsService.invalidateCache()
    }
}
