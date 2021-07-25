import UIKit
import AVFoundation
import Vision

public final class FaceDetectionVM: NSObject {
    var callback: ((Result<[VNFaceObservation], Error>) -> Void)
    let captureService: CaptureSessionServiceProtocol
    let permissionService: CheckPermissionServiceProtocol
    private var requests = [VNRequest]()
    
    let didClose: SimpleObservable<Bool> = SimpleObservable(false)
    let haveFaceRect: SimpleObservable<CGRect?> = SimpleObservable(nil)
    
    init(callback: @escaping ((Result<[VNFaceObservation], Error>) -> Void),
         captureService: CaptureSessionServiceProtocol,
         permissionService: CheckPermissionServiceProtocol) {
        
        self.callback = callback
        self.captureService = captureService
        self.permissionService = permissionService
    }
    
    public func configure(_ view: UIView) {
        permissionService.checkPermissions { [weak self] result in
            guard let self = self else { return }
            
            if case let .failure(error) = result {
                self.callback(.failure(error))
                self.didClose.value = true
            } else {
                self.startSession(view)
            }
        }
    }
    
    private func startSession(_ view: UIView) {
        captureService.startSession(delegate: self,
                                    view: view,
                                    position: .front,
                                    completion: { [weak self] result in
            guard let self = self else { return }
                                            
            if case let .failure(error) = result {
                self.callback(.failure(error))
                self.didClose.value = true
            }
        })

        setupVision()
    }
    
    public func stopSession() {
        captureService.stopSession()
    }
    
    public func switchCameraInput() {
        captureService.switchCameraInput()
    }
    
    private func setupVision() {
        let faceRequest = VNDetectFaceRectanglesRequest(completionHandler: self.faceDetectionHandler)
        self.requests = [faceRequest]
    }
    
    private func faceDetectionHandler(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNFaceObservation] else { return }
        let result = observations.compactMap { $0 }
        if result.isEmpty {
            haveFaceRect.value = nil
        } else {
            haveFaceRect.value = result.first?.boundingBox
            callback(.success(result))
        }
    }
}

extension FaceDetectionVM: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput,
                              didOutput sampleBuffer: CMSampleBuffer,
                              from connection: AVCaptureConnection) {
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer,
                                                        orientation: .up,
                                                        options: [:])
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
// TODO:
//        if !takePicture {
//            return // We have nothing to do with the image buffer
//        }
//
//        // Try and get a CVImageBuffer out of the sample buffer
//        guard let cvBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
//            return
//        }
//
//        // Get a CIImage out of the CVImageBuffer
//        let ciImage = CIImage(cvImageBuffer: cvBuffer)
//
//        // Get UIImage out of CIImage
//        let uiImage = UIImage(ciImage: ciImage)
//
//        DispatchQueue.main.async {
//            self.capturedImageView.image = uiImage
//            self.takePicture = false
//        }
    }
}
