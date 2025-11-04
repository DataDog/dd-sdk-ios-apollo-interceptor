// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "DatadogApollo",
    platforms: [
        .iOS(.v15),
        .tvOS(.v15),
        .macOS(.v12),
        .watchOS(.v8)
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
            .upToNextMajor(from: "2.0.0")
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
