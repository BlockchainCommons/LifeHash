// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "LifeHash",
    platforms: [
        .iOS(.v13), .macOS(.v10_15), .tvOS(.v13)
    ],
    products: [
        .library(
            name: "LifeHash",
            targets: ["LifeHash"]),
        ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "LifeHash",
            dependencies: [
            ])
        ]
)
