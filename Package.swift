// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ListInserter",
    platforms: [.iOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ListInserter",
            targets: ["ListInserter"]),
    ],
    targets: [
        .target(
            name: "ListInserter"),
        .testTarget(
            name: "ListInserterTests",
            dependencies: ["ListInserter"]),
    ]
)
