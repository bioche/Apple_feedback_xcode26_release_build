//
//  UserProductsService.swift
//  GSMODApplianceSelectionKit
//
//  Created by MESTIRI Hedi on 26/08/2019.
//  Copyright © 2019 groupeseb. All rights reserved.
//

import Foundation

import RxSwift

/// Answer to product creation request sent in client gateway.
public enum ProductCreationOutcome {
    /// The client application has accepted the request & created the user product.
    case created(UserProduct)
    /// The client application denied the creation of the product.
    /// Use this if the application is not responsible for this product's creation.
    /// (Ex: the product will be created by IOT during pairing flow)
    case deniedCreation
    
    public var product: UserProduct? {
        switch self {
        case .created(let userProduct):
            return userProduct
        case .deniedCreation:
            return nil
        }
    }
}

/// Service to communicate with application or another module
public protocol UserProductsService {
    
    /// All calls to fetch one or many user products after this should give refreshed user products
    ///
    /// - Returns: Observable that emits on invalidation done
    func invalidateCache() -> Observable<Void>
    
    /// Retrieve from listener all products registered in user account.
    ///
    /// - Returns: Observable of user product array
    func allUserProducts() -> Observable<[UserProduct]>
    
    /// Retrieve from listener product with specified id.
    /// Send `SelectedApplianceError.productNotFound` if the product couldn't be found.
    ///
    /// - Parameter productId: Product id
    /// - Returns: Observable of user product
    func userProduct(productId: ProductId) -> Observable<UserProduct>
    
    /// Ask if a specified product has an update available.
    ///
    /// - Parameter productId: Id of the product should be checked
    /// - Returns: Observable boolean. Returns YES if an update is available
    func checkUpdateFirmware(productId: ProductId) -> Observable<Bool>
    
    /// Asks client app to create the user product.
    /// If the response is `created`, the module will persist the selected appliance
    /// & send a `SelectedAppliance` as the module's completion
    /// Otherwise, the module will just send the request back as the module's completion
    /// (ex: the creation is not performed by app but by IOT)
    ///
    /// - Parameter appliance: Appliance added by user
    /// - Returns: Observable on the answer.
    func requestProductCreation(_ appliance: Appliance, kitchenware: [String], capacity: Capacity?, nickname: String?) -> Observable<ProductCreationOutcome>
    
    /// Client app should perform an update of product in user profile.
    /// Send `SelectedApplianceError.productNotFound` if the product couldn't be found.
    ///
    /// - Parameter product: Product updated by user
    /// - Returns: Observable on the updated product
    func updateProduct(_ product: UserProduct) -> Observable<UserProduct>
    
    /// Client app should perform a removal of product in user profile
    /// The module deletes it from local store
    /// Send `SelectedApplianceError.productNotFound` if the product couldn't be found.
    ///
    /// - Parameter productId: The id of product to be removed
    /// - Returns: Observable that will emit next when the removal is performed
    func removeProduct(_ productId: ProductId) -> Observable<Void>
    
}
