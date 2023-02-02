// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "StripeGrailed",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "StripeCardScanGrailed",
            targets: ["StripeCardScanGrailed"]
        ),
    ],
    targets: [
        .target(
            name: "StripeCardScanGrailed",
            dependencies: ["StripeCore"],
            path: "StripeCardScan/StripeCardScan",
            exclude: ["Info.plist"],
            resources: [
                .process("Resources/CompiledModels")
            ]
        ),
    ]
)
