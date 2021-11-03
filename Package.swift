// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "OMGHTTPURLRQ",
    platforms: [
        .iOS(.v9),
        .tvOS(.v9),
        .watchOS(.v2),
        .macOS(.v10_10)
    ],
    products: [
        .library(
            name: "OMGHTTPURLRQ",
            targets: ["OMGHTTPURLRQ"]),
        .library(
            name: "OMGHTTPURLRQUserAgent",
            targets: ["OMGHTTPURLRQUserAgent"]),
        .library(
            name: "OMGHTTPURLRQFormURLEncode",
            targets: ["OMGHTTPURLRQFormURLEncode"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "OMGHTTPURLRQ",
            dependencies: [
                "OMGHTTPURLRQUserAgent",
                "OMGHTTPURLRQFormURLEncode"
            ],
            path: "Sources/RQ",
            publicHeadersPath: "."),
        .target(
            name: "OMGHTTPURLRQUserAgent",
            path: "Sources/UserAgent",
            publicHeadersPath: "."),
        .target(
            name: "OMGHTTPURLRQFormURLEncode",
            path: "Sources/FormURLEncode",
            publicHeadersPath: "."),
        .testTarget(
            name: "OMGHTTPURLRQTests",
            dependencies: ["OMGHTTPURLRQ"],
            path: "Tests",
            exclude: ["Tests-Info.plist"]),
    ]
)
