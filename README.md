<!--
(C) 2026 Trulioo. All rights reserved.
-->

# Trulioo KYC Documents Capture iOS Guide

## Quick Summary

A standard iOS Capture integration looks like this:

1. add the `TruliooKYCDocumentsCapture` Swift package
2. initialize the runtime with a shortcode
3. create a camera for document or selfie capture
4. render the camera into a `UIView`
5. use `startFeedback(...)` for auto capture or `captureLatestFrame(...)` for manual capture
6. use `verifyImage()` and `acceptImage()` on the returned image result
7. call `submit(...)` when all required images have been accepted
8. call `reset()` when the host app is done with the transaction or needs a fresh session

## Package And Compatibility

- GitHub repository: `https://github.com/Trulioo/kyc-documents-capture.git`
- package name: `TruliooKYCDocumentsCapture`
- main runtime wrapper: `TruliooCaptureRuntimeLive`
- minimum iOS version: `15.0`

The public SwiftPM package includes:

- the binary `TruliooKYCDocumentsCapture` target
- the `TruliooKYCDocumentsCaptureRuntime` Swift bridge
- the upstream `Trulioo` dependency pinned by the package release metadata

## Platform Requirements And Dependencies

Host applications must:

- render the camera into a live `UIView`
- handle iOS camera permission flow
- provide a valid Capture shortcode
- decide whether a verified image should be accepted
- decide when the session should be submitted or reset

## Installation

Add the package:

```swift
dependencies: [
    .package(url: "https://github.com/Trulioo/kyc-documents-capture.git", from: "X.Y.Z")
]
```

For beta builds, pin the prerelease tag explicitly:

```swift
dependencies: [
    .package(url: "https://github.com/Trulioo/kyc-documents-capture.git", exact: "X.Y.Z-beta.N")
]
```

Link the products you use:

```swift
.target(
    name: "YourApp",
    dependencies: [
        .product(name: "TruliooKYCDocumentsCapture", package: "kyc-documents-capture"),
        .product(name: "TruliooKYCDocumentsCaptureRuntime", package: "kyc-documents-capture"),
    ]
)
```

Import the modules:

```swift
import Trulioo
import TruliooKYCDocumentsCapture
import TruliooKYCDocumentsCaptureRuntime
```

## Quick Start

```swift
import Trulioo
import TruliooKYCDocumentsCapture
import TruliooKYCDocumentsCaptureRuntime
import UIKit

final class CaptureHostViewController: UIViewController {
    private let capture = TruliooCaptureRuntimeLive()
    @IBOutlet private weak var cameraContainer: UIView!

    func startCapture(shortcode: String) {
        capture.initialize(
            shortcode: shortcode,
            options: Trulioo.InitializationOptions()
        ) { [weak self] error, transactionId in
            guard let self else { return }
            guard error == nil else {
                print("Initialize failed:", error!)
                return
            }

            print("Initialized transaction:", transactionId ?? "missing")

            let camera = self.capture.createCamera(
                config: ContractTruliooCameraConfig(
                    detectionType: .document
                )
            )

            camera.renderCamera(view: self.cameraContainer, cameraProps: nil)

            camera.startFeedback { error, response in
                guard error == nil, let response else {
                    print("Auto capture failed:", error!)
                    return
                }

                Task {
                    do {
                        let verify = try await response.verifyImage()
                        let accepted = verify.verifyResponses.contains { value in
                            value == "SUCCESS" || value == "SUCCESS_REQUIRES_BACK"
                        }

                        if accepted {
                            try await response.acceptImage()
                        }

                        self.capture.submit { submitError in
                            if let submitError {
                                print("Submit failed:", submitError)
                                return
                            }

                            self.capture.reset()
                        }
                    } catch {
                        print("Verify or accept failed:", error)
                    }
                }
            }
        }
    }
}
```

## Public Entry Points And When To Use Them

Main runtime entry points:

- `TruliooCaptureRuntimeLive.initialize(shortcode:options:locale:completion:)`
  Start or resume the active Capture transaction.
- `TruliooCaptureRuntimeLive.createCamera(config:)`
  Create a document or selfie camera instance for the active transaction.
- `TruliooCaptureRuntimeLive.submit(completion:)`
  Finalize the active transaction after the required images have been accepted.
- `TruliooCaptureRuntimeLive.reset()`
  Clear the active Capture state and prepare for a new initialization.

Main camera entry points:

- `renderCamera(view:cameraProps:)`
  Attach the camera to a host `UIView`.
- `startFeedback(...)`
  Run auto capture until the SDK accepts a candidate frame.
- `startFeedback(filter:result:)`
  Run auto capture with a caller-provided acceptance predicate.
- `captureLatestFrame(...)`
  Perform a manual capture from the latest available frame.
- `verifyImage()`
  Request post-capture verification feedback.
- `acceptImage()`
  Accept the image into the active transaction.
- `stopFeedback()`
  Stop an active auto-capture session.
- `onFeedbackState()`
  Observe SDK feedback labels through the bridged flow.
- `onCaptureRegion()`
  Observe the active capture region through the bridged flow.
- `getResolution(...)`
  Read the active camera stream resolution.
- `resume()`
  Resume preview after interruption or review.
- `remove()`
  Tear down the rendered camera and release resources.

## Initialization Flow

`initialize(...)`:

1. configures the Capture runtime bridge for the active session
2. authorizes the session from the shortcode
3. fetches Capture configuration
4. returns the active transaction id

Initialization must complete successfully before creating cameras.

If a newer initialize call supersedes an older one, the older completion may receive `TruliooCaptureInitializationSupersededError`.

## Capture Flow

The normal Capture flow is:

1. call `initialize(...)`
2. create a camera with `ContractTruliooCameraConfig`
3. render the camera into a `UIView`
4. call `startFeedback(...)` or `captureLatestFrame(...)`
5. inspect the result using `verifyImage()`
6. call `acceptImage()` if the host application wants to keep that image
7. repeat for additional required images
8. call `submit(...)`
9. call `reset()`

`submit(...)` finalizes the active transaction. `reset()` clears local Capture state and should be called before reusing the runtime for a new transaction.

## Caller-Owned Versus SDK-Owned Data

The host application owns:

- the shortcode
- the UIKit container and surrounding controls
- permission prompts and user guidance outside the camera component
- whether the current step is document or selfie
- whether to use auto capture or manual capture
- whether to accept the verified image
- when to submit or reset

The SDK owns:

- camera session setup and teardown
- frame analysis and auto-capture selection
- post-capture verification requests
- transaction-scoped image ids and feedback payloads
- accepted-image association with the active transaction

## Polling And Capture Defaults

The public iOS Capture contract does not require host configuration for upload pacing or frame timing.

Important defaults:

- document is the default detection type
- `startFeedback(...)` uses the SDK default acceptance behavior
- `submit(...)` does not clear local state by itself

## Result Handling

`startFeedback(...)` returns `TruliooCaptureResponse`.

Important fields:

- `imageId`
- `detectionType`
- `imageFeedbacks`

`verifyImage()` returns `ITruliooVerifyFeedback`.

Important fields:

- `isVerifyAttemptAvailable`
- `verifyResponses`

Recommended host-side acceptance rule:

- treat `SUCCESS` and `SUCCESS_REQUIRES_BACK` as accepted verify outcomes unless your product has a stricter policy

## Environment And Shortcode Rules

- always initialize with a shortcode created for the active transaction
- do not reuse a stale shortcode after `reset()`
- after calling `reset()`, a new `initialize(...)` call is required before reuse

## Common Mistakes

- creating a camera before initialization succeeds
- not retaining the runtime long enough for callbacks and async verify work
- assuming `submit(...)` also clears the local session
- treating an initialization-superseded error as a fatal product failure
- verifying the same image repeatedly after `isVerifyAttemptAvailable` is false

## Troubleshooting

- Initialization fails:
  Confirm the shortcode is valid and the host app is using the expected environment.
- Camera view stays blank:
  Confirm the `UIView` is attached, visible, and camera permission is granted.
- Auto capture never resolves:
  Inspect `onFeedbackState()` to see whether the SDK is repeatedly asking for a retake condition.
- Submit fails after capture:
  Confirm the expected images were accepted before submission.

## Support Handoff Checklist

When escalating an iOS Capture issue, collect:

- Capture SDK version
- iOS version and device model
- whether the flow was document or selfie
- whether the issue was auto capture or manual capture
- the returned transaction id when available
- the latest feedback state or verify responses
- whether the failure happened at initialize, capture, verify, accept, or submit
