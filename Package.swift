// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "RouteStack",
    platforms: [
      .iOS(.v16)
    ],
    products: [
        .library(
            name: "RouteStack",
            targets: ["RouteStack"]),
    ],
    targets: [
        .target(name: "RouteStack"),
    ]
)
