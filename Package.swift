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
        .package(url: "https://github.com/Trulioo/trulioo-ios.git", exact: "4.0.0-beta.0"),
    ],
    targets: [
        .binaryTarget(
            name: "TruliooKYCDocumentsCapture",
            url: "https://github.com/Trulioo/kyc-documents-capture/releases/download/4.0.0-beta.0/TruliooKYCDocumentsCapture.xcframework.zip",
            checksum: "b711082ad25eef87737d555759ef7b5282ebca077a4d11c2eeb0a4719d267592"
        ),
        .binaryTarget(
            name: "TruliooKYCDocumentsCaptureRuntime",
            url: "https://github.com/Trulioo/kyc-documents-capture/releases/download/4.0.0-beta.0/TruliooKYCDocumentsCaptureRuntime.xcframework.zip",
            checksum: "4cac8984583000d02983d431fd1a387a04de40135568cf82d1b0d9e0b5c8275a"
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
