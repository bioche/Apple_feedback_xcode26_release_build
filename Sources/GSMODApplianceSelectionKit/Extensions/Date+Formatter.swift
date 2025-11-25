//
//  Date+Formatter.swift
//
//
//  Created by Nicolas Favre on 14/03/2024.
//

import Foundation

extension Date {
    private static var dcpDateformatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS+SSSS"
        formatter.timeZone = .current
        formatter.calendar = Calendar(identifier: Calendar.Identifier.iso8601)
        formatter.locale = Locale(identifier: "\(Locale.current.identifier)_POSIX")
        return formatter
    }()
    
    /// Initialize a date from a string representation matching a custom DCP date format:
    ///
    /// - parameter client: A string conforming to string representation with a date format used by DCP
    ///
    /// - returns: A date instance if the input string is in correct format. returns nil otherwise
    init?(dcpFormattedString: String?) {
        if let inputString = dcpFormattedString, let date = Date.dcpDateformatter.date(from: inputString) {
            self.init(timeInterval: 0, since: date)
        } else {
            return nil
        }
    }
    
    func toString() -> String {
        return Date.dcpDateformatter.string(from: self)
    }

}
