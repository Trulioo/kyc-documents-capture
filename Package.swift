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
        .package(url: "https://github.com/Trulioo/trulioo-ios.git", exact: "4.1.0-beta.0"),
    ],
    targets: [
        .binaryTarget(
            name: "TruliooKYCDocumentsCapture",
            url: "https://github.com/Trulioo/kyc-documents-capture/releases/download/4.1.0-beta.0/TruliooKYCDocumentsCapture.xcframework.zip",
            checksum: "b3f486447cf7711c09887ccbb966b2e8d7b5041f0f212707e45adf0453718c80"
        ),
        .binaryTarget(
            name: "TruliooKYCDocumentsCaptureRuntime",
            url: "https://github.com/Trulioo/kyc-documents-capture/releases/download/4.1.0-beta.0/TruliooKYCDocumentsCaptureRuntime.xcframework.zip",
            checksum: "65f77dca768723818af971d43998112e9171afdbb1171f73b406dbd8ae35cabf"
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
