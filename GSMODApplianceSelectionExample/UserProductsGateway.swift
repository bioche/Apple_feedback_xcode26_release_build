//
//  UserProductsGateway.swift
//  ApplianceSelectionExemple
//
//  Created by MESTIRI Hedi on 26/08/2019.
//  Copyright © 2019 groupeseb. All rights reserved.
//

import Foundation

import GSMODApplianceSelectionKit
import GSMODApplianceSelectionView

import RxSwift

struct SampleProductDetailUIDatasource: ProductDetailUIDatasource {
    func shouldDisplayDeleteButton(selectedAppliance: SelectedAppliance, possibleAppliances: [Appliance]) -> Bool {
        possibleAppliances.count > 1
    }
    
    func getCustomInfos(selectedAppliance: SelectedAppliance) -> Observable<[ProductDetailCustomInfo]> {
        Bool.random() ? .just([ProductDetailCustomInfo("Long text description on two lines", "With associated value"), ProductDetailCustomInfo("Color", "Magenta")]) : .just([])
    }
}

struct MockError: Error { }

struct UserProductsGateway: UserProductsService {
   
    // Represent user products in DCP
    static var userProducts: [UserProduct] = []
    
    func allUserProducts() -> Observable<[UserProduct]> {
        return .just(UserProductsGateway.userProducts)
//        return .error(MockError()) // use this to use database exclusively like an unlogged Cookeat User
    }
    
    func userProduct(productId: ProductId) -> Observable<UserProduct> {
        guard let product = UserProductsGateway.userProducts.first(where: { $0.productId == productId }) else {
            return .error(SelectedApplianceError.productNotFound(productId: productId))
        }
        
        return .just(product)
    }
    
    func checkUpdateFirmware(productId: ProductId) -> Observable<Bool> {
        return .just(Bool.random())
    }
    
    func requestProductCreation(_ appliance: Appliance, kitchenware: [String], capacity: Capacity?, nickname: String?) -> Observable<ProductCreationOutcome> {
        log.info("UserProductsGateway - appliance added \(appliance)")
        
        let product = UserProduct(productId: UUID().uuidString, applianceId: appliance.applianceId, rawDomain: "PRO_COO", nickname: nickname, creationDate: Date.mock(), modificationDate: Date.mock())
        UserProductsGateway.userProducts.append(product)
        
        return Observable
            .just(.created(product))
            .delay(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
    }

    func updateProduct(_ product: UserProduct) -> Observable<UserProduct> {
        log.info("UserProductsGateway - product updated : \(product)")
        
        guard let indexProduct = UserProductsGateway.userProducts.firstIndex(where: { $0.productId == product.productId }) else {
            return .error(SelectedApplianceError.productNotFound(productId: product.productId))
        }
        
        UserProductsGateway.userProducts[indexProduct] = product
        
        return Observable
            .just(product)
            .delay(RxTimeInterval.milliseconds(100), scheduler: MainScheduler.asyncInstance)
    }
    
    func removeProduct(_ productId: ProductId) -> Observable<Void> {
        log.info("UserProductsGateway - products \(productId) removed")
        guard let indexProduct = UserProductsGateway.userProducts.firstIndex(where: { $0.productId == productId }) else {
            return .error(SelectedApplianceError.productNotFound(productId: productId))
        }
        
        UserProductsGateway.userProducts.remove(at: indexProduct)
        
        return Observable
            .just(())
            .delay(RxTimeInterval.milliseconds(100), scheduler: MainScheduler.asyncInstance)
    }
    
    func invalidateCache() -> Observable<Void> {
        return .just(())
    }
}
