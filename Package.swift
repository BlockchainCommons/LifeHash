// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "LifeHash",
    platforms: [
        .iOS(.v9), .macOS(.v10_13), .tvOS(.v11)
    ],
    products: [
        .library(
            name: "LifeHash",
            targets: ["LifeHash"]),
        ],
    dependencies: [
        .package(url: "https://github.com/wolfmcnally/WolfCore", from: "5.0.0"),
        .package(url: "https://github.com/wolfmcnally/WolfGraphics", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "LifeHash",
            dependencies: ["WolfCore", "WolfGraphics"])
        ]
)
