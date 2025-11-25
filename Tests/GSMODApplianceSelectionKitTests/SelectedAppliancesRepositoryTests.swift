//
//  SelectedAppliancesRepositoryTests.swift
//  GSMODApplianceSelectionKitTests
//
//  Created by MESTIRI Hedi on 30/08/2019.
//  Copyright © 2019 groupeseb. All rights reserved.
//

import XCTest



import RxSwift
import RxTest

@testable import GSMODApplianceSelectionKit

class SelectedAppliancesRepositoryTests: XCTestCase {
    var disposeBag = DisposeBag()
    var scheduler = TestScheduler(initialClock: 0)
    var factory: MockApplianceServicesFactory!
    
    override func setUp() {
        super.setUp()
        
        disposeBag = DisposeBag()
        scheduler = TestScheduler(initialClock: 0)
        factory = MockApplianceServicesFactory(
            configuration: .mock(),
            kitchenwaresNetworkService: .init(
                kitchenwaresResult: .success([Kitchenware.cookeoStub()])),
            fetchSAVUrlPath: { .just("https://www.apple.com") }
        )
    }
    
    func testGetSelectedAppliances() {
        let selectedAppliances = [SelectedAppliance.cookeoStub(), SelectedAppliance.companionStub(), SelectedAppliance.cakeFactoryStub()].sorted { $0.rawDomain < $1.rawDomain }
        
        let observer = scheduler.createObserver([SelectedAppliance].self)

        let recordedAppliances: Recorded<Event<[SelectedAppliance]>> = .next(0, selectedAppliances)
        let recorded: [Recorded<Event<[SelectedAppliance]>>] = [recordedAppliances,
                                                                .completed(0),
                                                                recordedAppliances,
                                                                .completed(0)]
        
        // Even if database is empty, the service will ask gateway to retrieve selected appliance
        factory
            .buildSelectedAppliancesService()
            .getSelectedAppliances()
            .map { $0.sorted { $0.rawDomain < $1.rawDomain } }
            .bind(to: observer)
            .disposed(by: disposeBag)
        
        factory
            .buildSelectedAppliancesService(simulateFailedRequest: true)
            .getSelectedAppliances()
            .map { $0.sorted { $0.rawDomain < $1.rawDomain } }
            .bind(to: observer)
            .disposed(by: disposeBag)
        
        scheduler.start()

        XCTAssertEqual(observer.events, recorded)
    }
    
    func testGetSelectedAppliancesWithDifferentProductsInGateway() {
        let selectedAppliances = [SelectedAppliance.cookeoStub(), SelectedAppliance.companionStub(), SelectedAppliance.cakeFactoryStub()].sorted { $0.rawDomain < $1.rawDomain }
        
        let observer = scheduler.createObserver([SelectedAppliance].self)
        
        let recordedAppliance: Recorded<Event<[SelectedAppliance]>> = .next(0, selectedAppliances)
        let recorded: [Recorded<Event<[SelectedAppliance]>>] = [recordedAppliance,
                                                                .completed(0),
                                                                recordedAppliance,
                                                                .completed(0)]
        
        // First we add an appliance in database
        factory
            .buildSelectedAppliancesService()
            .addSelectedAppliance(appliance: Appliance.cakeFactoryStub(), capacity: nil, kitchenwareIds: [], nickname: nil)
        
        // Ask for selected appliance
        // Repository will ask gateway first to retrieve selected appliance and replace it in database
        // We should receive products send by the gateway
        factory
            .buildSelectedAppliancesService()
            .getSelectedAppliances()
            .map { $0.sorted { $0.rawDomain < $1.rawDomain } }
            .bind(to: observer)
            .disposed(by: disposeBag)
        
        // If gateway send an error the repository will ask persistent store
        // The persistent store should have been updated with products provided by the gateway in previous call
        factory
            .buildSelectedAppliancesService(userProductsService: MockUserProductsGateway(sendErrorOnly: true))
            .getSelectedAppliances()
            .map { $0.sorted { $0.rawDomain < $1.rawDomain } }
            .bind(to: observer)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(observer.events, recorded)
    }
    
    func testGetSelectedAppliancesForDomain() {
        let observer = scheduler.createObserver([SelectedAppliance].self)

        let recorded: [Recorded<Event<[SelectedAppliance]>>] = [.next(0, [SelectedAppliance.cookeoStub()]),
                                                                .completed(0)]

        factory
            .buildSelectedAppliancesService()
            .getSelectedAppliances(for: "PRO_COO")
            .bind(to: observer)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(observer.events, recorded)
    }
    
    func testGetSelectedAppliance() {
        let selectedAppliance = SelectedAppliance.cookeoStub()
        
        let observer = scheduler.createObserver(SelectedAppliance.self)

        let recorded: [Recorded<Event<SelectedAppliance>>] = [.next(0, selectedAppliance),
                                                              .completed(0)]
        
        factory
            .buildSelectedAppliancesService()
            .getSelectedAppliance(productId: selectedAppliance.productId)
            .bind(to: observer)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(observer.events, recorded)
    }
    
    func testAddSelectedAppliance() {
        let selectedAppliance = SelectedAppliance.cookeoStub()
        
        let observer = scheduler.createObserver(SelectedAppliance?.self)

        let recorded: [Recorded<Event<SelectedAppliance?>>] = [.next(0, SelectedAppliance.cookeoStub()),
                                                               .completed(0)]
        
        factory
            .buildSelectedAppliancesService()
            .addSelectedAppliance(appliance: selectedAppliance.appliance,
                                  capacity: selectedAppliance.selectedCapacity,
                                  kitchenwareIds: selectedAppliance.selectedKitchenware,
                                  nickname: nil)
            .bind(to: observer)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(observer.events, recorded)
    }
    
    func testUpdateAppliance() {
        let selectedAppliance = SelectedAppliance.cookeoStub()
        var updatedAppliance = selectedAppliance
        updatedAppliance.nickname = "Nickname Updated"
        
        let observer = scheduler.createObserver(SelectedAppliance.self)

        let recorded: [Recorded<Event<SelectedAppliance>>] = [.next(0, updatedAppliance),
                                                              .completed(0)]
        
        factory
            .buildSelectedAppliancesService()
            .addSelectedAppliance(appliance: selectedAppliance.appliance,
                                  capacity: selectedAppliance.selectedCapacity,
                                  kitchenwareIds: selectedAppliance.selectedKitchenware,
                                  nickname: nil)
        
        factory
            .buildSelectedAppliancesService()
            .updateSelectedAppliance(updatedAppliance)
            .bind(to: observer)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(observer.events, recorded)
    }
    
    func testRemoveSelectedAppliance() {
        let selectedAppliance = SelectedAppliance.cookeoStub()
        
        let observer = scheduler.createObserver(Void.self)

        let recorded: [Recorded<Event<Void>>] = [.next(0, ()),
                                                 .completed(0)]
        
        factory
            .buildSelectedAppliancesService()
            .addSelectedAppliance(appliance: selectedAppliance.appliance,
                                  capacity: selectedAppliance.selectedCapacity,
                                  kitchenwareIds: selectedAppliance.selectedKitchenware,
                                  nickname: nil)
        
        factory
            .buildSelectedAppliancesService()
            .removeSelectedAppliance(productId: selectedAppliance.productId)
            .bind(to: observer)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertTrue(observer.events.count == recorded.count)
        
        if observer.events.count == recorded.count {
            observer.events.enumerated().forEach { (offset, event) in
                let secondEvent = recorded[offset]
                
                XCTAssertTrue(event.debugDescription == secondEvent.debugDescription)
            }
        }
    }
    
    func testGetSelectedKitchenwares() {
        let selectedAppliance = SelectedAppliance.cookeoStubWithKitchenwares()

        let observer = scheduler.createObserver([Kitchenware].self)
        let recorded: [Recorded<Event<[Kitchenware]>>] = [.next(0, [Kitchenware.cookeoStub()]), .completed(0)]

        factory
            .buildSelectedAppliancesService()
            .addSelectedAppliance(appliance: selectedAppliance.appliance,
                                  capacity: selectedAppliance.selectedCapacity,
                                  kitchenwareIds: selectedAppliance.selectedKitchenware,
                                  nickname: nil)
            .flatMap { _ in
                self.factory
                    .buildSelectedAppliancesService()
                    .getSelectedKitchenwares(productId: selectedAppliance.productId)
            }
            .bind(to: observer)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(observer.events, recorded)
    }
    
    func testNumberOfSelectedAppliances() {
        let observer = scheduler.createObserver(Int.self)

        let recorded: [Recorded<Event<Int>>] = [.next(0, 3),
                                                .completed(0)]
        
        factory
            .buildSelectedAppliancesService()
            .numberOfSelectedAppliances()
            .bind(to: observer)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(observer.events, recorded)
    }
    
    func testCheckUpdateFirmware() {
        let cookeo = SelectedAppliance.cookeoStub()
        let cakeFactory = SelectedAppliance.cakeFactoryStub()
        
        let observer = scheduler.createObserver(Bool.self)

        let recorded: [Recorded<Event<Bool>>] = [.next(0, true),
                                                 .completed(0),
                                                 .next(0, false),
                                                 .completed(0),
                                                 .error(0, SelectedApplianceError.productNotFound(productId: ""))]
        
        factory
            .buildSelectedAppliancesService()
            .checkUpdateFirmare(productId: cookeo.productId)
            .bind(to: observer)
            .disposed(by: disposeBag)
        
        factory
            .buildSelectedAppliancesService()
            .checkUpdateFirmare(productId: cakeFactory.productId)
            .bind(to: observer)
            .disposed(by: disposeBag)
        
        factory
            .buildSelectedAppliancesService()
            .checkUpdateFirmare(productId: "")
            .bind(to: observer)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(observer.events, recorded)
    }
}
