// swift-tools-version:5.9
// Builds and tests SoundLampCore without Xcode (`swift test`).
// The app itself is built from project.yml via XcodeGen.
import PackageDescription

let package = Package(
    name: "SoundLampCore",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "SoundLampCore", targets: ["SoundLampCore"]),
    ],
    targets: [
        .target(name: "SoundLampCore", path: "Sources/SoundLampCore"),
        .testTarget(name: "SoundLampCoreTests", dependencies: ["SoundLampCore"], path: "Tests/SoundLampCoreTests"),
    ],
    swiftLanguageVersions: [.v5]
)
