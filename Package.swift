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
            url: "https://github.com/pinpoint-positioning/Pinpoint-iOS-SDK/releases/download/12.2.1/PinpointSDK.xcframework.zip",
            checksum: "2db13dc74652d0bdf5055577c35914a3da57aacf06a248c219da27ba7731fdeb"
        ),
    ]
)
