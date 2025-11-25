//
//  MockAutoDetectionService.swift
//  GSMODApplianceSelection
//
//  Created by Thibault POUJAT on 12/09/2025.
//

public struct MockAutoDetectionService: AutoDetectionService {

    public init() { }

    public func startAppliancesDiscovery() -> AsyncStream<[String]> {
        return AsyncStream.init { _ in
            
        }
    }
}
