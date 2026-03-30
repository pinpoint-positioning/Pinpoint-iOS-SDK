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
            url: "https://github.com/pinpoint-positioning/Pinpoint-iOS-SDK/releases/download/12.2.2/PinpointSDKFramework.zip",
            checksum: "57e99f25d274e6e1d091fbeb46e3a45b38c83102ad10b353a00a04137ce6a44b"
        ),
    ]
)
