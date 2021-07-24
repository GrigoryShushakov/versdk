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
    
    public func transformRect(fromRect: CGRect , toViewRect :UIView) -> CGRect {
        //Convert Vision Frame to UIKit Frame
        var toRect = CGRect()
        toRect.size.width = fromRect.size.width * toViewRect.frame.size.width
        toRect.size.height = fromRect.size.height * toViewRect.frame.size.height
        toRect.origin.y = (toViewRect.frame.height) - (toViewRect.frame.height * fromRect.origin.y)
        toRect.origin.y = toRect.origin.y - toRect.size.height
        toRect.origin.x = (toViewRect.frame.width) - (toViewRect.frame.width * fromRect.origin.x)
        toRect.origin.x = toRect.origin.x - toRect.size.width
        return toRect
        
    }

    public func createBoxView(withColor : UIColor) -> UIView {
        let view = UIView()
        view.layer.borderColor = withColor.cgColor
        view.layer.borderWidth = 2
        view.backgroundColor = UIColor.clear
        return view
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
        
//        if !takePicture {
//            return //we have nothing to do with the image buffer
//        }
//
//        //try and get a CVImageBuffer out of the sample buffer
//        guard let cvBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
//            return
//        }
//
//        //get a CIImage out of the CVImageBuffer
//        let ciImage = CIImage(cvImageBuffer: cvBuffer)
//
//        //get UIImage out of CIImage
//        let uiImage = UIImage(ciImage: ciImage)
//
//        DispatchQueue.main.async {
//            self.capturedImageView.image = uiImage
//            self.takePicture = false
//        }
    }
}
