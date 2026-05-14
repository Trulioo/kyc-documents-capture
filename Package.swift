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
            targets: ["TruliooKYCDocumentsCaptureRuntime"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Trulioo/trulioo-ios.git", exact: "3.1.0-beta.1"),
    ],
    targets: [
        .binaryTarget(
            name: "TruliooKYCDocumentsCapture",
            url: "https://github.com/Trulioo/kyc-documents-capture/releases/download/3.1.0-beta.1/TruliooKYCDocumentsCapture.xcframework.zip",
            checksum: "16b61b4d7c912a7901a32caa2fa975a6c4f1976e509293c98378c71953a0f4c2"
        ),
        .binaryTarget(
            name: "TruliooKYCDocumentsCaptureRuntime",
            url: "https://github.com/Trulioo/kyc-documents-capture/releases/download/3.1.0-beta.1/TruliooKYCDocumentsCaptureRuntime.xcframework.zip",
            checksum: "be13dd4e1be93cbc1219c77b2dc2b205ecc3c2abd287edc2d4effb56fb6c0897"
        ),
        .target(
            name: "TruliooKYCDocumentsCaptureDependencies",
            dependencies: [
                "TruliooKYCDocumentsCaptureRuntime",
                .product(name: "Trulioo", package: "trulioo-ios"),
            ]
        )
    ]
)
