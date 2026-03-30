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
            url: "https://github.com/pinpoint-positioning/Pinpoint-iOS-SDK/releases/download/12.2.3/PinpointSDKFramework.zip",
            checksum: "e5a75122b5b8b3ee4118a141fcf00c99c6adbbac34c774865c764d6c80752f54"
        ),
    ]
)
