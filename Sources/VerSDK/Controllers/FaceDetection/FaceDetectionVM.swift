import UIKit
import AVFoundation
import Vision

final class FaceDetectionVM: NSObject {
    var callback: ((Result<UIImage, Error>) -> Void)
    let captureService: CaptureSessionServiceProtocol
    let permissionService: CheckPermissionServiceProtocol
    var takeShot = false
    
    // Vision requests for face detection
    private var requests = [VNRequest]()
    
    // Custom observables, for binding changes to ui layer
    let didClose: SimpleObservable<Bool> = SimpleObservable(false)
    let haveFaceRect: SimpleObservable<CGRect?> = SimpleObservable(nil)
    
    init(callback: @escaping ((Result<UIImage, Error>) -> Void),
         captureService: CaptureSessionServiceProtocol,
         permissionService: CheckPermissionServiceProtocol) {
        
        self.callback = callback
        self.captureService = captureService
        self.permissionService = permissionService
    }
    
    func configure(_ view: UIView) {
        permissionService.checkPermissions { [weak self] result in
            guard let self = self else { return }
            
            if case let .failure(error) = result {
                self.didClose.value = true
                self.callback(.failure(error))
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
                self.didClose.value = true
                self.callback(.failure(error))
            }
        })

        setupVision()
    }
    
    func stopSession() {
        captureService.stopSession()
    }
    
    func switchCameraInput() {
        captureService.switchCameraInput()
    }
    
    private func setupVision() {
        let faceRequest = VNDetectFaceRectanglesRequest(completionHandler: self.faceDetectionHandler)
        self.requests = [faceRequest]
    }
    
    private func faceDetectionHandler(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNFaceObservation] else { return }
        let result = observations.compactMap { $0 }
        if result.isEmpty || result.count > 1 {
            haveFaceRect.value = nil
        } else {
            haveFaceRect.value = result.first?.boundingBox
        }
    }
// TODO:
//    func transform(rect: CGRect, to viewRect :CGRect) -> CGRect {
//        return VNImageRectForNormalizedRect(rect, Int(viewRect.width), Int(viewRect.height))
//    }
}

extension FaceDetectionVM: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
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

        if takeShot {
            takeShot = false
            // Try and get a CVImageBuffer out of the sample buffer
            guard let cvBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

            // Get a CIImage out of the CVImageBuffer
            let ciImage = CIImage(cvImageBuffer: cvBuffer)

            // Get UIImage out of CIImage
            let uiImage = UIImage(ciImage: ciImage)

            self.didClose.value = true
            DispatchQueue.main.async {
                self.callback(.success(uiImage))
            }
        }
    }
}
