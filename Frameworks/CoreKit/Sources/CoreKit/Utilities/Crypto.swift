//
//  Crypto.swift
//  CoreKit
//
//  Created by Shiva Huang on 2020/7/2.
//  Copyright © 2020 AILabs. All rights reserved.
//

import CommonCrypto
import Foundation

public enum HashingAlgorithm {
    case sha1
    case sha256
}

/// The sizes that a symmetric cryptographic key can take.
public struct SymmetricKeySize {
    public let bitCount: Int

    /// Symmetric key size of 128 bits
    public static var bits128: SymmetricKeySize {
        return self.init(bitCount: 128)
    }

    /// Symmetric key size of 192 bits
    public static var bits192: SymmetricKeySize {
        return self.init(bitCount: 192)
    }

    /// Symmetric key size of 256 bits
    public static var bits256: SymmetricKeySize {
        return self.init(bitCount: 256)
    }

    /// Symmetric key size with a custom number of bits.
    ///
    /// - Parameter bitsCount: Positive integer that is a multiple of 8.
    public init(bitCount: Int) {
        precondition(bitCount > 0 && bitCount % 8 == 0)
        self.bitCount = bitCount
    }
}

public typealias SymmetricKey = Data

public extension SymmetricKey {
    init(size: SymmetricKeySize) {
        var bytes: [UInt8] = Array(repeating: 0, count: size.bitCount / 8)
        CCRandomGenerateBytes(&bytes, bytes.count)
        self = Data(bytes: bytes, count: bytes.count)
    }
}

public extension Data {
    ///  Computes the hash digest of the bytes using the given hash algorithm and returns the computed digest.
    /// - Parameter algorithm: The hash function you want to use.
    /// - Returns: The computed digest.
    func hash(using algorithm: HashingAlgorithm) -> Data {
        switch algorithm {
        case .sha1:
            var digest = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
            
            _ = self.withUnsafeBytes {
                CC_SHA1($0.baseAddress, UInt32(self.count), &digest)
            }
            
            return Data(digest)
            
        case .sha256:
            var digest = [UInt8](repeating: 0, count:Int(CC_SHA256_DIGEST_LENGTH))
            
            _ = self.withUnsafeBytes {
                CC_SHA256($0.baseAddress, UInt32(self.count), &digest)
            }
            
            return Data(digest)
        }
    }

    ///  Computes the HMAC digest of the bytes using the given hash algorithm and symmetric key, returns the computed digest.
    /// - Parameter algorithm: The hash function you want to use.
    /// - Parameter symmetricKey: The symmetric key used to secure the computation.
    /// - Returns: The computed digest.
    func hmac(using algorithm: HashingAlgorithm, symmetricKey: SymmetricKey) -> Data {
        var digest: [UInt8]
        let hmacAlgorithm: CCHmacAlgorithm

        switch algorithm {
        case .sha1:
            digest = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
            hmacAlgorithm = CCHmacAlgorithm(kCCHmacAlgSHA1)

        case .sha256:
            digest = [UInt8](repeating: 0, count:Int(CC_SHA256_DIGEST_LENGTH))
            hmacAlgorithm = CCHmacAlgorithm(kCCHmacAlgSHA256)
        }

        self.withUnsafeBytes { (bytes) -> Void in
            symmetricKey.withUnsafeBytes { (symmetricKeyBytes) -> Void in
                CCHmac(hmacAlgorithm, symmetricKeyBytes.baseAddress, symmetricKey.count, bytes.baseAddress, self.count, &digest)
            }
        }

        return Data(digest)
    }
}

public extension String {
    /// Computes the hash digest of the string using the given hash algorithm and returns the computed digest.
    /// - Parameter algorithm: The hash function you want to use.
    /// - Returns: The computed digest.
    func hash(using algorithm: HashingAlgorithm) -> Data {
        guard let data = self.data(using: .utf8) else {
            return Data()
        }
        
        return data.hash(using: algorithm)
    }

    /// Computes the HMAC digest of the string using the given hash algorithm and symmetric key, returns the computed digest.
    /// - Parameter algorithm: The hash function you want to use.
    /// - Parameter symmetricKey: The symmetric key used to secure the computation.
    /// - Returns: The computed digest.
    func hmac(using algorithm: HashingAlgorithm, symmetricKey: SymmetricKey) -> Data {
        guard let data = self.data(using: .utf8) else {
            return Data()
        }

        return data.hmac(using: algorithm, symmetricKey: symmetricKey)
    }
}
