import TruliooKYCDocumentsCapture
import TruliooKYCDocumentsCaptureRuntime
import Trulioo

public enum TruliooKYCDocumentsCaptureRuntimeDependencies {
    public static func forceLink() {
        _ = TruliooCapture.self
        _ = TruliooCaptureRuntimeLive.self
        _ = TruliooURLSessionFactory.self
    }
}
