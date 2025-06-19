// swift-tools-version:5.5
import PackageDescription

let package = Package(
  name: "InteractiveZoomDriver",
  platforms: [.iOS(.v13)],
  products: [
    .library(name: "InteractiveZoomDriver", targets: ["InteractiveZoomDriver"]),
  ],
  dependencies: [
  ],
  targets: [
    .target(
      name: "InteractiveZoomDriver",
      exclude: ["Info.plist"]
    ),
  ]
)
