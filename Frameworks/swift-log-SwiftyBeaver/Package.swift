// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-log-SwiftyBeaver",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "LoggingSwiftyBeaver",
            targets: ["LoggingSwiftyBeaver"]),
    ],
    dependencies: [
        // Swift logging API
        .package(url: "https://github.com/apple/swift-log.git", from: "1.3.0"),
        
        .package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git", .upToNextMajor(from: "1.9.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "LoggingSwiftyBeaver",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                "SwiftyBeaver",
        ]),
        .testTarget(
            name: "LoggingSwiftyBeaverTests",
            dependencies: ["LoggingSwiftyBeaver"]),
    ]
)
