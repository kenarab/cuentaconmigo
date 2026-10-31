// swift-tools-version: 5.9
import PackageDescription

// Platform-neutral domain core: no UI, camera or storage. Its behavior is defined by
// the shared contracts in /contracts and verified against their conformance vectors.
let package = Package(
    name: "TelegramaCore",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [.library(name: "TelegramaCore", targets: ["TelegramaCore"])],
    targets: [
        .target(name: "TelegramaCore"),
        .testTarget(name: "TelegramaCoreTests", dependencies: ["TelegramaCore"])
    ]
)
