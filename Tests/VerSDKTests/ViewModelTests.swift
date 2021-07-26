import XCTest
import AVFoundation
@testable import VerSDK

final class ViewModelTests: XCTestCase {
    
    var captureService: CaptureSessionServiceProtocol!
    var permissionService: CheckPermissionServiceProtocol!
    
    override func setUpWithError() throws {
        permissionService = CheckPermissionServiceMock()
        captureService = CaptureSessionServiceMock()
    }

    func testViewModel() {
        let viewModel = RecognizeVM(callback: {_ in },
                                    captureService: captureService,
                                    permissionService: permissionService)
        viewModel.configure(UIView())
        XCTAssert(viewModel.takeShot == false)
        XCTAssertNil(viewModel.haveFoundText.value)
    }
}

private class CaptureSessionServiceMock: CaptureSessionServiceProtocol {
    func startSession(delegate: AVCaptureVideoDataOutputSampleBufferDelegate,
                      view: UIView,
                      position: AVCaptureDevice.Position,
                      completion: ((Result<Void, Error>) -> Void)) {}
    func stopSession() {}
    func switchCameraInput() {}
}

private class CheckPermissionServiceMock: CheckPermissionServiceProtocol {
    func checkPermissions(completion: @escaping (Result<Void, Error>) -> ()) {}
}
