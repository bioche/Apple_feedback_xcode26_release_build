//
//  AppliancesRepositoryTests.swift
//  GSMODApplianceSelectionKitTests
//
//  Created by Olivier Tavel on 28/08/2019.
//  Copyright © 2019 groupeseb. All rights reserved.
//

import XCTest



import RxSwift
import RxTest
import RxCocoa

@testable import GSMODApplianceSelectionKit

class AppliancesRepositoryTests: XCTestCase {
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
    
    func testGetAppliances() {
        let observer = scheduler.createObserver([Appliance].self)
        let recorded: [Recorded<Event<[Appliance]>>] = [.next(0, [.cakeFactoryStub(), .companionStub(), .cookeoStub(), .aspirobotStub()]), .completed(0)]
        
        factory.kitchenwaresNetworkService.kitchenwaresResult = .failure(WebClientError.emptyResponse)
        
        let appliancesService = factory.buildAppliancesService()
        appliancesService
            .getAppliances()
            .bind(to: observer)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(observer.events, recorded)
    }
    
    func testGetAppliancesCache() {
        let observer = scheduler.createObserver([Appliance].self)
        
        let recorded: [Recorded<Event<[Appliance]>>] = [
            .next(0, [.cakeFactoryStub(), .companionStub(), .cookeoStub(), .aspirobotStub()]),
            .completed(0),
            .next(0, [.cakeFactoryStub(), .companionStub(), .cookeoStub(), .aspirobotStub()]), .completed(0)
        ]

        factory.kitchenwaresNetworkService.kitchenwaresResult = .success([.cakeFactoryStub(), .companionStub(), .cookeoStub(), .aspirobotStub()])
        
        // service with success request
        let appliancesServiceSuccessRequest = factory.buildAppliancesService()
        // service without failed request
        let appliancesServiceFailureRequest = factory.buildAppliancesService(simulateFailedRequest: true)
        
        // Call first the success request, the response should be save in database
        appliancesServiceSuccessRequest
            .getAppliances()
            .bind(to: observer)
            .disposed(by: disposeBag)
        
        // If the previous response was saved in database, the service will provide cache response
        appliancesServiceFailureRequest
            .getAppliances()
            .bind(to: observer)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(observer.events, recorded)
    }

    func testGetAppliancesForDomain() {
        let observer = scheduler.createObserver([Appliance].self)
        let recorded: [Recorded<Event<[Appliance]>>] = [.next(0, [.cookeoStub()]), .completed(0)]
        
        let appliancesService = factory.buildAppliancesService()
        appliancesService
            .getAppliances(for: "PRO_COO")
            .bind(to: observer)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(observer.events, recorded)
    }
    
    func testGetApplianceSuccess() {
        let observer = scheduler.createObserver(Appliance.self)
        let recorded: [Recorded<Event<Appliance>>] = [.next(0, .companionStub()), .completed(0)]
        
        let appliancesService = factory.buildAppliancesService()
        appliancesService
            .getAppliance(for: Appliance.companionStub().applianceId)
            .bind(to: observer)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(observer.events, recorded)
    }
}
