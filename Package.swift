// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "LangPerApp",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "LangPerApp",
            path: "Sources/LangPerApp"
        )
    ]
)
