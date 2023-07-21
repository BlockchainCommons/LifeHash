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
        .package(name: "CLifeHash", url: "https://github.com/BlockchainCommons/bc-lifehash", from: "0.4.1")
    ],
    targets: [
        .target(
            name: "LifeHash",
            dependencies: [
                "CLifeHash"
            ])
        ]
)
