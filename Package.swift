// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "LifeHash",
    platforms: [
        .iOS(.v13), 
        .macOS(.v11),
        .tvOS(.v13)
    ],
    products: [
        .library(
            name: "LifeHash",
            targets: ["LifeHash"]),
        ],
    dependencies: [
        .package(url: "https://github.com/BlockchainCommons/bc-lifehash", from: "0.4.1")
    ],
    targets: [
        .target(
            name: "LifeHash",
            dependencies: [
                .product(name: "CLifeHash", package: "bc-lifehash")
            ])
        ]
)
