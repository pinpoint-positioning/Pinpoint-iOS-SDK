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
            url: "https://github.com/pinpoint-positioning/Pinpoint-iOS-SDK/releases/download/12.2.4/PinpointSDKFramework.zip",
            checksum: "911cf94951f1249f5084f27f722e4a032bf044e1736e238855d76613fbb33387"
        ),
    ]
)
