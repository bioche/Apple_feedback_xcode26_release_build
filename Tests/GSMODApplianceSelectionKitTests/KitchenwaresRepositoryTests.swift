//
//  KitchenwaresRepositoryTests.swift
//  GSMODApplianceSelectionKitTests
//
//  Created by Olivier Tavel on 29/08/2019.
//  Copyright © 2019 groupeseb. All rights reserved.
//

import XCTest

import RxSwift
import RxTest



@testable import GSMODApplianceSelectionKit

class KitchenwaresRepositoryTests: XCTestCase {
    var disposeBag = DisposeBag()
    var scheduler: TestScheduler!
    var factory: MockApplianceServicesFactory!
    
    override func setUp() {
        super.setUp()
        
        disposeBag = DisposeBag()
        scheduler = TestScheduler(initialClock: 0)
        factory = MockApplianceServicesFactory(
            configuration: .mock(),
            kitchenwaresNetworkService: .init(
                kitchenwaresResult: .success([Kitchenware.cookeoStub()])
            ),
            fetchSAVUrlPath: { .just("https://www.apple.com") }
        )
    }
    
    func testGetKitchenwares() {
        let observer = scheduler.createObserver([Kitchenware].self)
        let recorded: [Recorded<Event<[Kitchenware]>>] = [.next(0, [Kitchenware.cakeFactoryStub()]), .completed(0)]
        
        guard let groupId = SelectedAppliance.cakeFactoryStub().group?.id else {
            return XCTAssertFalse(true, "Appliance has no group id")
        }

        factory.kitchenwaresNetworkService.kitchenwaresResult = .success([Kitchenware.cakeFactoryStub()])

        let kitchenwaresService = factory.buildKitchenwaresService()
        kitchenwaresService
            .getKitchenwares(applianceGroup: groupId)
            .bind(to: observer)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(observer.events, recorded)
    }
    
    func testGetKitchenwaresCache() {
        let observer = scheduler.createObserver([Kitchenware].self)
        let recorded: [Recorded<Event<[Kitchenware]>>] = [.next(0, [Kitchenware.cakeFactoryStub()]), .completed(0), .next(0, [Kitchenware.cakeFactoryStub()]), .completed(0)]
        
        guard let groupId = SelectedAppliance.cakeFactoryStub().group?.id else {
            return XCTAssertFalse(true, "Appliance has no group id")
        }
        
        // service with success request
        let kitchenwaresServiceSuccessRequest = factory.buildKitchenwaresService()
        // service without failed request
        factory.kitchenwaresNetworkService.kitchenwaresResult = .failure(WebClientError.emptyResponse)
        
        let kitchenwaresServiceFailureRequest = factory.buildKitchenwaresService()
        
        // Call first the success request, the response should be save in database
        kitchenwaresServiceSuccessRequest
            .getKitchenwares(applianceGroup: groupId)
            .bind(to: observer)
            .disposed(by: disposeBag)
        
        // If the previous response was saved in databae, the service will provide cache response
        kitchenwaresServiceFailureRequest
            .getKitchenwares(applianceGroup: groupId)
            .bind(to: observer)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(observer.events, recorded)
    }
}
