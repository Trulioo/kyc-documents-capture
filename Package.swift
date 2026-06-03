// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "TruliooKYCDocumentsCapture",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "TruliooKYCDocumentsCapture",
            targets: ["TruliooKYCDocumentsCapture", "TruliooKYCDocumentsCaptureDependencies"]
        ),
        .library(
            name: "TruliooKYCDocumentsCaptureRuntime",
            targets: ["TruliooKYCDocumentsCaptureRuntime", "TruliooKYCDocumentsCaptureRuntimeDependencies"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Trulioo/trulioo-ios.git", exact: "3.1.0-beta.3"),
    ],
    targets: [
        .binaryTarget(
            name: "TruliooKYCDocumentsCapture",
            url: "https://github.com/Trulioo/kyc-documents-capture/releases/download/3.1.0-beta.3/TruliooKYCDocumentsCapture.xcframework.zip",
            checksum: "1b7286235ad2fe451bb35199019f997aba72b40ed8f86370d3252ac9f3ed11f8"
        ),
        .binaryTarget(
            name: "TruliooKYCDocumentsCaptureRuntime",
            url: "https://github.com/Trulioo/kyc-documents-capture/releases/download/3.1.0-beta.3/TruliooKYCDocumentsCaptureRuntime.xcframework.zip",
            checksum: "6294f50ef7d8a5eef3328dad2ecf24867d9effc191acb97677aa5fb70ea1356c"
        ),
        .target(
            name: "TruliooKYCDocumentsCaptureDependencies",
            dependencies: [
                "TruliooKYCDocumentsCaptureRuntime",
                .product(name: "Trulioo", package: "trulioo-ios"),
            ]
        ),
        .target(
            name: "TruliooKYCDocumentsCaptureRuntimeDependencies",
            dependencies: [
                "TruliooKYCDocumentsCapture",
                "TruliooKYCDocumentsCaptureRuntime",
                .product(name: "Trulioo", package: "trulioo-ios"),
            ]
        )
    ]
)
