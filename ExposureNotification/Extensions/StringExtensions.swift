//
//  StringExtensions.swift
//  ExposureNotification
//
//  Created by Chuck on 2022/4/1.
//  Copyright © 2022 AI Labs. All rights reserved.
//

import Foundation

extension String {
    enum Base45Error: Error {
        case invalidCharacter
        case invalidLength
        case dataOverflow
    }
    
    public func fromBase45() throws -> Data {
        let BASE45_CHARSET = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ $%*+-./:"
        let base: UInt32 = 45
        var temp = Data()
        var output = Data()
        
        for char in self.uppercased() {
            guard let index = BASE45_CHARSET.firstIndex(of: char) else {
                throw Base45Error.invalidCharacter
            }
            
            temp.append(UInt8(BASE45_CHARSET.distance(from: BASE45_CHARSET.startIndex, to: index)))
        }
        
        for i in stride(from: 0, to: temp.count, by: 3) {
            guard temp.count - i >= 2 else {
                throw Base45Error.invalidLength
            }
            
            var x: UInt32 = UInt32(temp[i]) + UInt32(temp[i+1]) * base
            if (temp.count - i >= 3) {
                x += base * base * UInt32(temp[i+2])
                
                guard x / 256 <= UInt8.max else {
                    throw Base45Error.dataOverflow
                }
                
                output.append(UInt8(x / 256))
            }
            output.append(UInt8(x % 256))
        }
        return output
    }
    
    var trimmed: String {
        trimmingCharacters(in: .whitespaces)
    }
}
