import XCTest
import AVFoundation
@testable import VerSDK

final class ViewModelTests: XCTestCase {
    
    var captureService: CaptureSessionServiceProtocol!
    
    override func setUpWithError() throws {
        captureService = CaptureSessionServiceMock()
    }

    func testViewModel() {
        let viewModel = RecognizeVM(callback: {_ in },
                                    captureService: captureService)
        viewModel.checkPermissions { result in
            guard case .success(let value) = result else {
                return XCTFail("Expected to be a success but got a failure with \(result)")
            }
            XCTAssertNotNil(value)
        }
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
