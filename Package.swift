// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PinpointSDK",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PinpointSDK",
            targets: ["PinpointSDK"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "PinpointSDK",
            url: "https://github.com/pinpoint-positioning/Pinpoint-iOS-SDK/releases/download/12.1.0/PinpointSDK.xcframework.zip",
            checksum: "a12c4753e0916ef583671a4e46c4c28854073944cc9421d294a60b00fcd6b10e"
        ),
    ]
)
