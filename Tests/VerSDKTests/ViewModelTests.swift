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
        XCTAssert(viewModel.takeShot == false)
        XCTAssertNil(viewModel.haveFoundText.value)
        XCTAssertTrue(viewModel.boxes.isEmpty)
    }
}

private class CaptureSessionServiceMock: CaptureSessionServiceProtocol {
    var captureSession: AVCaptureSession = AVCaptureSession()
    func startSession(delegate: AVCaptureVideoDataOutputSampleBufferDelegate,
                      position: AVCaptureDevice.Position,
                      completion: ((Result<Void, Error>) -> Void)) {}
    func stopSession() {}
    func switchCameraInput() {}
}

private class CheckPermissionServiceMock: CheckPermissionServiceProtocol {
    func checkPermissions(completion: @escaping (Result<Void, Error>) -> ()) {}
}
