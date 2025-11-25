//
//  Observable+ApplianceSelectionKit.swift
//  GSMODApplianceSelectionKit
//
//  Created by MESTIRI Hedi on 27/08/2019.
//  Copyright © 2019 groupeseb. All rights reserved.
//

import Foundation

import RxSwift
import RealmSwift
import Realm

public extension ObservableType where Element == SelectedAppliance {
    func retrieveKitchenwares(kitchenwaresService: KitchenwaresService) -> Observable<(SelectedAppliance, [Kitchenware])> {
        return self
            .flatMap { selectedAppliance -> Observable<(SelectedAppliance, [Kitchenware])> in
                // If group id is empty return empty array
                guard let groupId = selectedAppliance.group?.id else {
                    return Observable.just((selectedAppliance, []))
                }
                
                // Fetch kitchenwares for specific appliance
                return Observable.zip(Observable.just(selectedAppliance),
                                      kitchenwaresService
                                        .getKitchenwares(applianceGroup: groupId)
                                        .catchAndReturn([]))
            }
    }
}

extension ObservableType where Element == SelectedApplianceRealm {
    func toSelectedAppliance(
        appliancesService: AppliancesService,
        store: SelectedAppliancesPersistentStore
    ) -> Observable<SelectedAppliance> {
        flatMap { selectedApplianceRealm -> Observable<SelectedAppliance> in
            appliancesService
                .getAppliance(for: selectedApplianceRealm.applianceId)
                .catch { error in
                    switch error {
                    case ApplianceError.applianceNotFound(let applianceId):
                        log.error("Couldn't find appliance with id \(applianceId). Clearing it from database")
                        try store.realmInstance.write {
                            store.realmInstance.delete(selectedApplianceRealm, cascading: true)
                        }
                        return .empty()
                    default:
                        return .error(error)
                    }
                }
                .map { selectedApplianceRealm.toSelectedAppliance(with: $0) }
        }
    }
}

extension ObservableType where Element == UserProduct {
    func toSelectedAppliance(
        appliancesService: AppliancesService,
        selectedAppliancesService: SelectedAppliancesService
    ) -> Observable<SelectedAppliance> {
        flatMap { (userProduct) -> Observable<SelectedAppliance> in
            appliancesService
                .getAppliance(for: userProduct.applianceId)
                .catch { error in
                    // in case the appliance doesn't exist in this market,
                    // we delete it from user profile
                    // avoids killing accounts with old test appliances or appliances deleted from market
                    switch error {
                    case ApplianceError.applianceNotFound(let applianceId):
                        log.error("Couldn't find appliance with id \(applianceId). Clearing it from user products")
                        return selectedAppliancesService
                            .removeSelectedAppliance(productId: userProduct.productId)
                            .flatMap { Observable.empty() }
                    default:
                        return .error(error)
                    }
                }
                .map { userProduct.toSelectedAppliance(appliance: $0) }
        }
    }
    
}

extension ObservableType where Element == [UserProduct] {
    func toSelectedAppliances(
        appliancesService: AppliancesService,
        selectedAppliancesService: SelectedAppliancesService
    ) -> Observable<[SelectedAppliance]> {
        flatMapLatest { Observable.from($0) }
            .toSelectedAppliance(
                appliancesService: appliancesService,
                selectedAppliancesService: selectedAppliancesService
            )
            .toArray()
            .asObservable()
    }
}

// Implementation of this gist : https://gist.github.com/krodak/b47ea81b3ae25ca2f10c27476bed450c
// You need to implement CascadeDeletable protocol and specify the properties to delete in cascade
protocol CascadeDeleting {
    @available(iOS, deprecated, message: "Realm v10 support natively cascade deleting see this post: https://www.mongodb.com/developer/article/realm-database-cascading-deletes/#cascading-deletes. Be careful when migrating : https://docs.mongodb.com/realm/sdk/ios/examples/modify-an-object-schema/#convert-from-object-to-embeddedobject")
    func delete<S: Sequence>(_ objects: S, cascading: Bool) where S.Iterator.Element: Object
    
    @available(iOS, deprecated, message: "Realm v10 support natively cascade deleting see this post: https://www.mongodb.com/developer/article/realm-database-cascading-deletes/#cascading-deletes. Be careful when migrating : https://docs.mongodb.com/realm/sdk/ios/examples/modify-an-object-schema/#convert-from-object-to-embeddedobject")
    func delete<Entity: Object>(_ entity: Entity, cascading: Bool)
}

extension Realm: CascadeDeleting {
    @available(iOS, deprecated, message: "Realm v10 support natively cascade deleting see this post: https://www.mongodb.com/developer/article/realm-database-cascading-deletes/#cascading-deletes. Be careful when migrating : https://docs.mongodb.com/realm/sdk/ios/examples/modify-an-object-schema/#convert-from-object-to-embeddedobject")
    public func delete<S: Sequence>(_ objects: S, cascading: Bool) where S.Iterator.Element: Object {
        for obj in objects {
            delete(obj, cascading: cascading)
        }
    }
    
    @available(iOS, deprecated, message: "Realm v10 support natively cascade deleting see this post: https://www.mongodb.com/developer/article/realm-database-cascading-deletes/#cascading-deletes. Be careful when migrating : https://docs.mongodb.com/realm/sdk/ios/examples/modify-an-object-schema/#convert-from-object-to-embeddedobject")
    public func delete<Entity: Object>(_ entity: Entity, cascading: Bool) {
        if cascading {
            cascadeDelete(entity)
        } else {
            delete(entity)
        }
    }
}

private extension Realm {
    private func cascadeDelete(_ entity: RLMObjectBase) {
        guard let entity = entity as? Object else { return }
        var toBeDeleted = Set<RLMObjectBase>()
        toBeDeleted.insert(entity)
        while !toBeDeleted.isEmpty {
            guard let element = toBeDeleted.removeFirst() as? Object,
                !element.isInvalidated else { continue }
            resolve(element: element, toBeDeleted: &toBeDeleted)
        }
    }
    
    private func resolve(element: Object, toBeDeleted: inout Set<RLMObjectBase>) {
        if let cascadingObject = element as? CascadeDeletable {
            element.objectSchema.properties.forEach {
                if cascadingObject.propertiesToCascadeDelete.contains($0.name) {
                    guard let value = element.value(forKey: $0.name) else { return }
                    if let entity = value as? RLMObjectBase {
                        toBeDeleted.insert(entity)
                    } else if let list = value as? RLMSwiftCollectionBase {
                        for index in 0..<list._rlmCollection.count {
                            if let realmObject = list._rlmCollection.object(at: index) as? RLMObjectBase {
                                toBeDeleted.insert(realmObject)
                            }
                        }
                    }
                }
            }
        }
        delete(element)
    }
}

@available(iOS, deprecated, message: "Realm v10 support natively cascade deleting see this post: https://www.mongodb.com/developer/article/realm-database-cascading-deletes/#cascading-deletes. Be careful when migrating : https://docs.mongodb.com/realm/sdk/ios/examples/modify-an-object-schema/#convert-from-object-to-embeddedobject")
public protocol CascadeDeletable: AnyObject {
    var propertiesToCascadeDelete: [String] { get }
}
