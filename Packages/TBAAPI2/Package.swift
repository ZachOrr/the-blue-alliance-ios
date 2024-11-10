// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TBAAPI2",
    platforms: [.iOS(.v18)],
    products: [
        .library(
            name: "TBAAPI",
            targets: [
                "TBAAPI"
            ])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.2.0"),
        .package(url: "https://github.com/apple/swift-openapi-generator", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-openapi-urlsession", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "TBAAPI",
            dependencies: [
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "OpenAPIURLSession", package: "swift-openapi-urlsession"),
            ],
            plugins: [
                .plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator"),
            ]
        ),
        /*
        .executableTarget(
            name: "TBAAPI-main",
            dependencies: ["TBAAPI"]
        )
        */
        .testTarget(
            name: "TBAAPITests",
            dependencies: ["TBAAPI"]
        )
    ]
)
