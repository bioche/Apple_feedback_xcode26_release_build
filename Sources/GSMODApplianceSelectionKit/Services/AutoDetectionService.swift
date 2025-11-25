//
//  AutoDetectionService.swift
//  GSMODApplianceSelection
//
//  Created by Thibault POUJAT on 12/09/2025.
//

public protocol AutoDetectionService {

    func startAppliancesDiscovery() -> AsyncStream<[String]>
}
