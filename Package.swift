// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Sensor",
    platforms: [
       .macOS(.v10_13),
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Sensor",
            targets: ["Sensor"]),
        .library(
            name: "SensorTest",
            targets: ["SensorTest"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/NoTests/RxFeedback.swift.git", from: "3.0.0")
    ],
    targets: [
        .target(
            name: "Sensor",
            dependencies: ["RxFeedback"],
            path: "Sensor/Sources"),
        .testTarget(
            name: "SensorUnitTests",
            dependencies: ["Sensor", "SensorTest"],
            path: "Sensor/UnitTests"),
        .target(
            name: "SensorTest",
            dependencies: [],
            path: "SensorTest/Sources"),
        .testTarget(
            name: "SensorTestUnitTests",
            dependencies: ["SensorTest", "SnapshotTesting"],
            path: "SensorTest/UnitTests"),
    ]
)
