// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "EasylocateSDK",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "EasylocateSDK",
            targets: ["EasylocateSDK"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "EasylocateSDK",
            url: "https://github.com/pinpoint-positioning/EasylocateSDK/releases/download/12.1.0/EasylocateSDK.xcframework.zip",
            checksum: "8f024f8801dfdf3abd67a85a5932a3544cd0eeede3c09a4b26084bdc9e59142f"
        ),
    ]
)
