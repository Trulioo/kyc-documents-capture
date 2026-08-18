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
        .package(url: "https://github.com/Trulioo/trulioo-ios.git", exact: "3.3.0"),
    ],
    targets: [
        .binaryTarget(
            name: "TruliooKYCDocumentsCapture",
            url: "https://github.com/Trulioo/kyc-documents-capture/releases/download/3.3.0/TruliooKYCDocumentsCapture.xcframework.zip",
            checksum: "07b76d745a59c5789a851939e69d112773b8b8921d4d3476d1ffe0bce244d6e4"
        ),
        .binaryTarget(
            name: "TruliooKYCDocumentsCaptureRuntime",
            url: "https://github.com/Trulioo/kyc-documents-capture/releases/download/3.3.0/TruliooKYCDocumentsCaptureRuntime.xcframework.zip",
            checksum: "8acef5f863a8c4c14a340f7254b0459eefe92da364032ad2a46fdbeacc16930f"
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
