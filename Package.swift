// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "JGProgressHUD-SwiftUI",
    platforms: [.iOS(.v14), .tvOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "JGProgressHUD-SwiftUI",
            targets: ["JGProgressHUD-SwiftUI"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/JonasGessner/JGProgressHUD.git", .branch("master")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "JGProgressHUD-SwiftUI",
            dependencies: [.product(name: "JGProgressHUD", package: "JGProgressHUD")]),
        .testTarget(
            name: "JGProgressHUD-SwiftUITests",
            dependencies: ["JGProgressHUD-SwiftUI"]),
    ]
)

