/*
 This source file is part of the Swift.org open source project

 Copyright (c) 2018 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception

 See http://swift.org/LICENSE.txt for license information
 See http://swift.org/CONTRIBUTORS.txt for Swift project authors
*/

// Source:
//     - https://github.com/apple/swift-package-manager/blob/master/Sources/PackageDescription/Version.swift
//     - https://github.com/apple/swift-package-manager/blob/master/Sources/PackageDescription/Version%2BStringLiteralConvertible.swift

/// A version according to the semantic versioning specification.
///
/// A package version is a three period-separated integer, for example `1.0.0`. It must conform to the semantic versioning standard in order to ensure
/// that your package behaves in a predictable manner once developers update their
/// package dependency to a newer version. To achieve predictability, the semantic versioning specification proposes a set of rules and
/// requirements that dictate how version numbers are assigned and incremented. To learn more about the semantic versioning specification, visit
/// [semver.org](www.semver.org).
/// 
/// **The Major Version**
///
/// The first digit of a version, or  *major version*, signifies breaking changes to the API that require
/// updates to existing clients. For example, the semantic versioning specification
/// considers renaming an existing type, removing a method, or changing a method's signature
/// breaking changes. This also includes any backward-incompatible bug fixes or
/// behavioral changes of the existing API.
///
/// **The Minor Version**
///
/// Update the second digit of a version, or *minor version*, if you add functionality in a backward-compatible manner.
/// For example, the semantic versioning specification considers adding a new method
/// or type without changing any other API to be backward-compatible.
///
/// **The Patch Version**
///
/// Increase the third digit of a version, or *patch version*, if you are making a backward-compatible bug fix.
/// This allows clients to benefit from bugfixes to your package without incurring
/// any maintenance burden.
public struct Version {

    /// The major version according to the semantic versioning standard.
    public let major: Int

    /// The minor version according to the semantic versioning standard.
    public let minor: Int

    /// The patch version according to the semantic versioning standard.
    public let patch: Int

    /// The pre-release identifier according to the semantic versioning standard, such as `-beta.1`.
    public let prereleaseIdentifiers: [String]

    /// The build metadata of this version according to the semantic versioning standard, such as a commit hash.
    public let buildMetadataIdentifiers: [String]

    /// Initializes a version struct with the provided components of a semantic version.
    ///
    /// - Parameters:
    ///     - major: The major version numner.
    ///     - minor: The minor version number.
    ///     - patch: The patch version number.
    ///     - prereleaseIdentifiers: The pre-release identifier.
    ///     - buildMetaDataIdentifiers: Build metadata that identifies a build.
    public init(
        major: Int,
        minor: Int = 0,
        patch: Int = 0,
        prereleaseIdentifiers: [String] = [],
        buildMetadataIdentifiers: [String] = []
    ) {
        precondition(major >= 0 && minor >= 0 && patch >= 0, "Negative versioning is invalid.")
        self.major = major
        self.minor = minor
        self.patch = patch
        self.prereleaseIdentifiers = prereleaseIdentifiers
        self.buildMetadataIdentifiers = buildMetadataIdentifiers
    }
}

extension Version: Comparable {
    public static func < (lhs: Version, rhs: Version) -> Bool {
        let lhsComparators = [lhs.major, lhs.minor, lhs.patch]
        let rhsComparators = [rhs.major, rhs.minor, rhs.patch]

        if lhsComparators != rhsComparators {
            return lhsComparators.lexicographicallyPrecedes(rhsComparators)
        }

        guard lhs.prereleaseIdentifiers.count > 0 else {
            return false // Non-prerelease lhs >= potentially prerelease rhs
        }

        guard rhs.prereleaseIdentifiers.count > 0 else {
            return true // Prerelease lhs < non-prerelease rhs 
        }

        let zippedIdentifiers = zip(lhs.prereleaseIdentifiers, rhs.prereleaseIdentifiers)
        for (lhsPrereleaseIdentifier, rhsPrereleaseIdentifier) in zippedIdentifiers {
            if lhsPrereleaseIdentifier == rhsPrereleaseIdentifier {
                continue
            }

            let typedLhsIdentifier: Any = Int(lhsPrereleaseIdentifier) ?? lhsPrereleaseIdentifier
            let typedRhsIdentifier: Any = Int(rhsPrereleaseIdentifier) ?? rhsPrereleaseIdentifier

            switch (typedLhsIdentifier, typedRhsIdentifier) {
                case let (int1 as Int, int2 as Int): return int1 < int2
                case let (string1 as String, string2 as String): return string1 < string2
                case (is Int, is String): return true // Int prereleases < String prereleases
                case (is String, is Int): return false
            default:
                return false
            }
        }

        return lhs.prereleaseIdentifiers.count < rhs.prereleaseIdentifiers.count
    }
}

extension Version: CustomStringConvertible {
    /// A textual description of the version object.
    public var description: String {
        var base = "\(major).\(minor).\(patch)"
        if !prereleaseIdentifiers.isEmpty {
            base += "-" + prereleaseIdentifiers.joined(separator: ".")
        }
        if !buildMetadataIdentifiers.isEmpty {
            base += "+" + buildMetadataIdentifiers.joined(separator: ".")
        }
        return base
    }
}

extension Version: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        
        guard let version = Version(value) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid semantic version string '\(value)'")
        }
        
        self.init(version)
    }
}

extension Version: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description)
    }
}

extension Version: ExpressibleByStringLiteral {

    /// Initializes a version struct with the provided string literal.
    ///
    /// - Parameters:
    ///     - value: A string literal to use for creating a new version struct.
    /// - Returns: A version struct with the provided information. If version can't be initialized using the string literal, a dummy value of version 0.0.0 is returned.
    public init(stringLiteral value: String) {
        if let version = Version(value) {
            self.init(version)
        } else {
            self.init(major: 0)
        }
    }

    /// Initializes a version struct with the provided extended grapheme cluster.
    ///
    /// - Parameters:
    ///     - version: An extended grapheme cluster to use for creating a new version struct.
    public init(extendedGraphemeClusterLiteral value: String) {
        self.init(stringLiteral: value)
    }

    /// Initializes a version struct with the provided Unicode string.
    ///
    /// - Parameters:
    ///     - version: A Unicode string to use for creating a new version struct.
    public init(unicodeScalarLiteral value: String) {
        self.init(stringLiteral: value)
    }
}

extension Version {

    /// Initializes a version struct with the provided version.
    ///
    /// - Parameters:
    ///     - version: A version object to use for creating a new version struct.
    public init(_ version: Version) {
        major = version.major
        minor = version.minor
        patch = version.patch
        prereleaseIdentifiers = version.prereleaseIdentifiers
        buildMetadataIdentifiers = version.buildMetadataIdentifiers
    }

    /// Initializes a version struct with the provided version string.
    ///
    /// - Parameters:
    ///     - version: A version string to use for creating a new version struct.
    public init?(_ versionString: String) {
        let prereleaseStartIndex = versionString.firstIndex(of: "-")
        let metadataStartIndex = versionString.firstIndex(of: "+")

        let requiredEndIndex = prereleaseStartIndex ?? metadataStartIndex ?? versionString.endIndex
        let requiredCharacters = versionString.prefix(upTo: requiredEndIndex)
        let requiredComponents = requiredCharacters
            .split(separator: ".", maxSplits: 2, omittingEmptySubsequences: false)
            .map(String.init)
            .compactMap({ Int($0) })
            .filter({ $0 >= 0 })

        guard requiredComponents.count == 3 else { return nil }

        self.major = requiredComponents[0]
        self.minor = requiredComponents[1]
        self.patch = requiredComponents[2]

        func identifiers(start: String.Index?, end: String.Index) -> [String] {
            guard let start = start else { return [] }
            let identifiers = versionString[versionString.index(after: start)..<end]
            return identifiers.split(separator: ".").map(String.init)
        }

        self.prereleaseIdentifiers = identifiers(
            start: prereleaseStartIndex,
            end: metadataStartIndex ?? versionString.endIndex)
        self.buildMetadataIdentifiers = identifiers(start: metadataStartIndex, end: versionString.endIndex)
    }
}
