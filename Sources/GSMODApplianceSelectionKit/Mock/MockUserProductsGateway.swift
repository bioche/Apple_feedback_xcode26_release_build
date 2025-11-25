//
//  MockUserProductsGateway.swift
//  GSMODApplianceSelectionKitTests
//
//  Created by Olivier Tavel on 28/08/2019.
//  Copyright © 2019 groupeseb. All rights reserved.
//

import Foundation

import RxSwift

public struct MockUserProductsGateway: UserProductsService {

    let sendErrorOnly: Bool

    public init(sendErrorOnly: Bool = false) {
        self.sendErrorOnly = sendErrorOnly
    }

    public func allUserProducts() -> Observable<[UserProduct]> {
        guard !sendErrorOnly else {
            return .error(SelectedApplianceError.productsNotFound)
        }

        return .just([UserProduct.cookeoStub(), UserProduct.companionStub(), UserProduct.cakeFactoryStub()])
    }

    public func userProduct(productId: ProductId) -> Observable<UserProduct> {
        guard !sendErrorOnly else {
            return .error(SelectedApplianceError.productNotFound(productId: productId))
        }

        if productId.contains("COOKEO") {
            return .just(UserProduct.cookeoStub())
        } else if productId.contains("COMPANION") {
            return .just(UserProduct.companionStub())
        } else if productId.contains("CAKEFACTORY") {
            return .just(UserProduct.cakeFactoryStub())
        } else if productId.contains("ASPIROBOT") {
            return .just(UserProduct.aspirobotStub())
        }

        return .error(SelectedApplianceError.productNotFound(productId: productId))
    }

    public func checkUpdateFirmware(productId: ProductId) -> Observable<Bool> {
        guard !sendErrorOnly else {
            return .error(SelectedApplianceError.productNotFound(productId: productId))
        }

        if productId.contains("COOKEO") {
            return .just(true)
        } else if productId.contains("COMPANION") {
            return .just(true)
        } else if productId.contains("CAKEFACTORY") {
            return .just(false)
        }

        return .error(SelectedApplianceError.productNotFound(productId: productId))
    }

    public func requestProductCreation(_ appliance: Appliance, kitchenware: [String], capacity: Capacity?, nickname: String?) -> Observable<ProductCreationOutcome> {
        guard !sendErrorOnly else {
            return .error(ApplianceError.appliancesNotFound)
        }

        switch appliance.applianceId {
        case Appliance.cookeoStub().applianceId:
            return .just(.created(UserProduct.cookeoStub()))
        case Appliance.companionStub().applianceId:
            return .just(.created(UserProduct.companionStub()))
        case Appliance.cakeFactoryStub().applianceId:
            return .just(.created(UserProduct.cakeFactoryStub()))
        default:
            return .error(SelectedApplianceError.productsNotFound)
        }
    }

    public func updateProduct(_ product: UserProduct) -> Observable<UserProduct> {
        guard !sendErrorOnly else {
            return .error(SelectedApplianceError.productNotFound(productId: product.productId))
        }

        return .just(product)
    }

    public func removeProduct(_ productId: ProductId) -> Observable<Void> {
        guard !sendErrorOnly else {
            return .error(SelectedApplianceError.productNotFound(productId: productId))
        }

        return .just(())
    }

    public func invalidateCache() -> Observable<Void> {
        return .just(())
    }
}
