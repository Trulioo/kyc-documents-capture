<!--
(C) 2026 Trulioo. All rights reserved.
-->

# Trulioo KYC Documents Capture iOS Guide

## Audience And Scope

Use this guide when integrating host-owned document or selfie camera capture into an iOS app.

This guide covers the public Swift package, Capture runtime initialization, camera controller embedding, image verification and acceptance, transaction submission, and support evidence. Use the KYC Documents iOS guide when the hosted KYC Documents UI owns the full document verification flow.

## Quick Summary

The Trulioo KYC Documents Capture iOS SDK provides document and selfie capture capabilities that can be embedded in an iOS host screen.

Customer applications can expect the SDK to:

- initialize the active capture transaction from a shortcode
- create a document or selfie camera for the active transaction
- return a camera `UIViewController` for UIKit embedding or SwiftUI bridging
- return capture feedback or manual capture results
- verify and accept captured images before submission
- submit accepted images and return iOS-native success or error callbacks

A standard iOS Capture integration looks like this:

1. add the `TruliooKYCDocumentsCapture` Swift package
2. initialize the runtime with a shortcode
3. create a camera for document or selfie capture
4. render the camera and embed the returned `UIViewController`
5. use `startFeedback(...)` for auto capture or `captureLatestFrame(...)` for manual capture
6. use `verifyImage()` and `acceptImage()` on the returned image result
7. call `submit(...)` when all required images have been accepted
8. call `reset()` when the host app is done with the transaction or needs a fresh session

## Package Or Artifact Identity

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

- embed the SDK-owned camera `UIViewController` into the host UI
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

Import the modules you use:

```swift
import TruliooKYCDocumentsCapture
import TruliooKYCDocumentsCaptureRuntime
```

Import `Trulioo` only when the host application also uses the base `Trulioo` SDK directly.

## Quick-Start Example

In your view controller or capture coordinator:

```swift
import TruliooKYCDocumentsCapture
import TruliooKYCDocumentsCaptureRuntime
import UIKit

final class CaptureCoordinator {
    private let capture = TruliooCaptureRuntimeLive()

    func startCapture(
        shortcode: String,
        presentCamera: @escaping (UIViewController) -> Void
    ) {
        capture.initialize(shortcode: shortcode) { [weak self] error, transactionId in
            guard let self else { return }
            if let error {
                print("Initialize failed:", error)
                return
            }

            print("Initialized transaction:", transactionId ?? "missing")

            let camera = self.capture.createCamera(
                config: ContractTruliooCameraConfig(
                    detectionType: .document
                )
            )

            let controller = camera.render(cameraProps: nil)
            presentCamera(controller)

            camera.startFeedback { error, response in
                if let error {
                    print("Auto capture failed:", error)
                    return
                }

                guard let response else {
                    print("Auto capture did not return an image")
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

                            camera.remove()
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

Embed or present the returned camera `UIViewController` using the host application's normal UIKit or SwiftUI container pattern.

When removing an embedded UIKit child controller, use the normal child-controller teardown sequence:

```swift
controller.willMove(toParent: nil)
controller.view.removeFromSuperview()
controller.removeFromParent()
```

Pair host UI teardown with `camera.remove()` when the camera instance is no longer needed.

## Public Entrypoints And When To Use Them

Main runtime entry points:

- `TruliooCaptureRuntimeLive.initialize(shortcode:locale:completion:)`
  Start or resume the active Capture transaction with default runtime options.
- `TruliooCaptureRuntimeLive.initialize(shortcode:options:locale:completion:)`
  Start or resume the active Capture transaction.
- `TruliooCaptureRuntimeLive.createCamera(config:)`
  Create a document or selfie camera instance for the active transaction.
- `TruliooCaptureRuntimeLive.submit(completion:)`
  Finalize the active transaction after the required images have been accepted.
- `TruliooCaptureRuntimeLive.reset()`
  Clear the active Capture state and prepare for a new initialization.

Main camera entry points:

- `render(cameraProps:)`
  Return an SDK-owned `UIViewController` that hosts the camera UI. Embed that controller in UIKit or bridge it into SwiftUI with `UIViewControllerRepresentable`.
- `startFeedback(...)`
  Run auto capture until the SDK accepts a candidate frame.
- `startFeedback(filter:result:)`
  Run auto capture with a caller-provided acceptance predicate.
- `captureLatestFrame(...)`
  Perform a manual capture from the latest available frame.
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

Capture result entry points:

- `verifyImage()`
  Request post-capture verification feedback. Call this on the `TruliooCaptureResponse` or `TruliooManualCaptureResponse` returned by `startFeedback(...)` or `captureLatestFrame(...)`.
- `acceptImage()`
  Accept the image into the active transaction. Call this on the `TruliooCaptureResponse` or `TruliooManualCaptureResponse` returned by `startFeedback(...)` or `captureLatestFrame(...)`.

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
3. call `render(cameraProps:)`
4. embed the returned `UIViewController`
5. call `startFeedback(...)` or `captureLatestFrame(...)`
6. inspect the result using `verifyImage()`
7. call `acceptImage()` if the host application wants to keep that image
8. repeat for additional required images
9. call `submit(...)`
10. call `reset()`
11. remove the embedded camera `UIViewController` from the parent hierarchy using the cleanup pattern above

`submit(...)` finalizes the active transaction. `reset()` clears local Capture state and should be called before reusing the runtime for a new transaction.

## Device Send Flow And Debug Wait Flow

The Device Intelligence send and debug wait paths do not apply to the Capture SDK. Capture submission is finalized through `submit(...)` after the required accepted images are associated with the active transaction.

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

## Polling Defaults

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

## Troubleshooting

- Initialization fails:
  Confirm the shortcode is valid and the host app is using the expected environment.
- Camera view stays blank:
  Confirm the returned camera `UIViewController` is retained, embedded in the active view hierarchy, and camera permission is granted.
- Auto capture never resolves:
  Inspect `onFeedbackState()` to see whether the SDK is repeatedly asking for a retake condition.
- Submit fails after capture:
  Confirm the expected images were accepted before submission.

## Diagnostic Capture Checklist

When escalating an iOS Capture issue, collect:

- Capture SDK version
- iOS version and device model
- whether the flow was document or selfie
- whether the issue was auto capture or manual capture
- the returned transaction id when available
- the latest feedback state or verify responses
- whether the failure happened at initialize, capture, verify, accept, or submit

## Support Handoff Checklist

When handing an issue to Trulioo support, include:

- the package version and release channel
- the shortcode environment, without sharing secrets in public tickets
- iOS version, device model, and host presentation mode
- capture step type: document or selfie
- whether capture used auto feedback or manual capture
- transaction id when available
- latest feedback state, verify responses, and failing stage
