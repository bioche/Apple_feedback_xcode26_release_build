//
//  SelectedAppliance+ArrayTests.swift
//  GSMODApplianceSelection
//
//  Created by Thibault POUJAT on 13/08/2025.
//

import XCTest
@testable import GSMODApplianceSelectionKit

final class SelectedApplianceArrayTests: XCTestCase {

    func generateAppliance(id: String, creationDate: Date?) -> SelectedAppliance {
        SelectedAppliance(
            appliance: Appliance(
                id: id,
                name: id,
                lang: "",
                market: "",
                capacities: [],
                media: nil,
                rawDomain: "",
                applianceFamily: nil,
                resource_uri: nil,
                group: nil,
                classifications: [],
                order: nil,
                thingType: nil
            ),
            creationDate: creationDate,
            modificationDate: nil
        )
    }

    /// Tests that appliances are sorted in ascending order by creation date.
    func testSortedByCreationDateSortsAscending() {
        let appliance1 = generateAppliance(
            id: "A",
            creationDate: Date.mock("2023-01-01-09:00:00")
        )
        let appliance2 = generateAppliance(
            id: "B",
            creationDate: Date.mock("2023-01-01-08:00:00")
        )
        let sorted = [appliance1, appliance2].sortedByCreationDate()
        XCTAssertEqual(sorted.map { $0.applianceId }, ["B", "A"])
    }

    /// Tests that appliances with nil creation dates are sorted before those with a date.
    func testSortedByCreationDateNilDatesComeFirst() {
        let appliance1 = generateAppliance(id: "A", creationDate: nil)
        let appliance2 = generateAppliance(id: "B", creationDate: Date.mock())
        let sorted = [appliance2, appliance1].sortedByCreationDate()
        XCTAssertEqual(sorted.map { $0.applianceId }, ["A", "B"])
    }

    /// Tests that when both appliances have nil creation dates, the original order is preserved (stable sort).
    func testSortedByCreationDateBothNilDatesStableSort() {
        let appliance1 = generateAppliance(id: "A", creationDate: nil)
        let appliance2 = generateAppliance(id: "B", creationDate: nil)
        let sorted = [appliance1, appliance2].sortedByCreationDate()
        XCTAssertEqual(sorted.map { $0.applianceId }, ["A", "B"])
    }

    /// Tests sorting with a mix of nil and non-nil creation dates, ensuring correct order.
    func testSortedByCreationDateMixedCases() {
        let appliance1 = generateAppliance(id: "A", creationDate: nil)
        let appliance2 = generateAppliance(
            id: "B",
            creationDate: Date.mock("2023-01-01-09:00:00")
        )
        let appliance3 = generateAppliance(
            id: "C",
            creationDate: Date.mock("2023-01-01-08:00:00")
        )
        let sorted = [appliance2, appliance1, appliance3].sortedByCreationDate()
        XCTAssertEqual(sorted.map { $0.applianceId }, ["A", "C", "B"])
    }
}
