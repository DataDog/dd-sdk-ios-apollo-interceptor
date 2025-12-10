// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "DatadogApollo",
    platforms: [
        .iOS(.v12),
        .tvOS(.v12),
        .macOS(.v12),
        .watchOS(.v7)
    ],
    products: [
        .library(
            name: "DatadogApollo",
            targets: ["DatadogApollo"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/apollographql/apollo-ios.git",
            .upToNextMajor(from: "1.0.0")
        )
    ],
    targets: [
        .target(
            name: "DatadogApollo",
            dependencies: [
                .product(name: "Apollo", package: "apollo-ios"),
                .product(name: "ApolloAPI", package: "apollo-ios")
            ]
        ),
        .testTarget(
            name: "DatadogApolloTests",
            dependencies: ["DatadogApollo"]
        )
    ]
)
