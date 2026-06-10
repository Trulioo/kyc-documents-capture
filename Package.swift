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
        .package(url: "https://github.com/Trulioo/trulioo-ios.git", exact: "3.1.0-beta.5"),
    ],
    targets: [
        .binaryTarget(
            name: "TruliooKYCDocumentsCapture",
            url: "https://github.com/Trulioo/kyc-documents-capture/releases/download/3.1.0-beta.5/TruliooKYCDocumentsCapture.xcframework.zip",
            checksum: "6ffe6bcbbadf7108c042c7f6697bb89ab044b728c36ca38605e8b288d63f14b3"
        ),
        .binaryTarget(
            name: "TruliooKYCDocumentsCaptureRuntime",
            url: "https://github.com/Trulioo/kyc-documents-capture/releases/download/3.1.0-beta.5/TruliooKYCDocumentsCaptureRuntime.xcframework.zip",
            checksum: "e9a566c8fbc4f34f56f24489c59cc9663ec19620d6174f95fffabec7e4fef0b3"
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
