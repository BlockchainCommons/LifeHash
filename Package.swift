// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "LifeHash",
    platforms: [
        .iOS(.v13), .macOS(.v11), .tvOS(.v13)
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
