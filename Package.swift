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
            checksum: "ccef2bb0b4866f2552d4cedb1ceed6be8bff987fee9e4282c2d7d9c717f55422"
        ),
    ]
)
