//
//  SampleCore+Extension.swift
//  GSMODApplianceSelectionExample
//
//  Created by Samir Tiouajni on 06/06/2024.
//  Copyright © 2024 groupeseb. All rights reserved.
//

import Foundation
import GSMODCore

extension SampleCore {
    static func deleteDocumentsDirectoryContents() -> EquatableError? {
        UserProductsGateway.userProducts = []
        let fileManager = FileManager.default
        let myDocuments = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        do {
            let filePaths = try fileManager.contentsOfDirectory(atPath: myDocuments.path)
            log.info("Documents directory: \(myDocuments.path)")
            for filePath in filePaths {
                try fileManager.removeItem(atPath: myDocuments.path + "/" + filePath)
            }
            
            return nil
        } catch let error {
            return error.equatable
        }
    }
}
