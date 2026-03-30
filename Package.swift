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
            url: "https://github.com/pinpoint-positioning/Pinpoint-iOS-SDK/releases/download/12.2.2/PinpointSDK.xcframework.zip",
            checksum: "2429c6fcebad539e0ad402cc6e0f88a752890cef57a86944811648d9ac1b71cb"
        ),
    ]
)
