// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PlaylistKit",
    platforms: [
        .iOS(.v10),
        .tvOS(.v10),
        .watchOS(.v4)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "PlaylistKit",
            targets: ["PlaylistKit"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
         .package(path: "ErrorKit"),
         .package(path: "ObserverKit")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "PlaylistKit",
            dependencies: ["ErrorKit"]),
        .testTarget(
            name: "PlaylistKitTests",
            dependencies: ["PlaylistKit"])
    ]
)
