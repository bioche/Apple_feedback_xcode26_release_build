//
//  SelectedAppliance+Array.swift
//  GSMODApplianceSelection
//
//  Created by Thibault POUJAT on 13/08/2025.
//

public extension Array where Element == SelectedAppliance {
    /// Returns a new array of `SelectedAppliance` elements sorted by their `creationDate` in ascending order.
    ///
    /// - Products with a non-nil `creationDate` are ordered from oldest to newest.
    /// - Products with a nil `creationDate` are considered older than those with a non-nil date and appear first in the sorted array.
    /// - If both products have nil `creationDate`, their relative order is preserved (stable sort).
    /// - The original array is not modified.
    ///
    func sortedByCreationDate() -> [SelectedAppliance] {
        self.sorted { lhs, rhs in
            switch (lhs.creationDate, rhs.creationDate) {
            case let (l?, r?):
                return l < r
            case (nil, _?):
                return true // lhs has no date, rhs does
            case (_?, nil):
                return false // rhs has no date, lhs does
            case (nil, nil):
                return false // both have no date
            }
        }
    }

}
