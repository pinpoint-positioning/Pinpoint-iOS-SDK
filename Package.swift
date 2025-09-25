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
            url: "https://github.com/pinpoint-positioning/EasylocateSDK/releases/download/12.1.0/PinpointSDK.xcframework.zip",
            checksum: "02272a94d2f5bc69b0c5e1e7b200c1ae6bf78cfd0465343333b19baaada3d662"
        ),
    ]
)
