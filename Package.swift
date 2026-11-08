// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "OpiekunIOS",
    defaultLocalization: "pl",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "OpiekunIOS",
            targets: ["OpiekunIOS"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "OpiekunIOS",
            path: "OpiekunIOS",
            exclude: ["Resources/Info.plist"]
        ),
    ]
)

