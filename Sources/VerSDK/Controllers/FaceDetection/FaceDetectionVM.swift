import UIKit
import AVFoundation
import Vision

final class FaceDetectionVM: NSObject, CheckPermissionProtocol {
    var callback: ((Result<UIImage, Error>) -> Void)
    let captureService: CaptureSessionServiceProtocol
    var takeShot = false
    
    // Preview frame rect for transformations
    var previewFrame = CGRect()
    
    // Vision requests for face and landmarks detection
    private var requests = [VNRequest]()
    
    // Points for draw closed eyes, UIKit coordinates
    var leftEyePoints: [CGPoint] = []
    var rightEyePoints: [CGPoint] = []
    
    // Custom observables, for binding changes to ui layer
    let didClose: SimpleObservable<Bool> = SimpleObservable(false)
    let haveFaceRect: SimpleObservable<CGRect?> = SimpleObservable(nil)
    let isCenter: SimpleObservable<Bool> = SimpleObservable(false)
    let eyesIsOpen: SimpleObservable<Bool> = SimpleObservable(false)
    let notRolled: SimpleObservable<Bool> = SimpleObservable(false)
    let notYawed: SimpleObservable<Bool> = SimpleObservable(false)
    
    init(callback: @escaping ((Result<UIImage, Error>) -> Void),
         captureService: CaptureSessionServiceProtocol) {
        
        self.callback = callback
        self.captureService = captureService
    }
    
    func configure(_ previewRect: CGRect) {
        self.previewFrame = previewRect
        checkPermissions { [weak self] result in
            guard let self = self else { return }
            
            if case let .failure(error) = result {
                self.didClose.value = true
                self.callback(.failure(error))
            } else {
                self.startSession()
            }
        }
    }
    
    private func startSession() {
        captureService.startSession(delegate: self,
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
        requests = []
    }
    
    private func setupVision() {
        let requests = VNDetectFaceLandmarksRequest(completionHandler: self.detectionHandler)
        self.requests = [requests]
    }
    
    private func detectionHandler(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNFaceObservation] else { return }
        let result = observations.compactMap { $0 }
        handleResult(result)
    }
    
    private func handleResult(_ result: [VNFaceObservation]) {
        // Only one face accepted
        if result.isEmpty || result.count > 1 {
            haveFaceRect.value = nil
            return
        } else {
            guard let faceRect = result.first?.boundingBox.transform(to: previewFrame) else { return }
            
            // Custom approach with some assumptions
            isCenter.value = faceRect.isCenterPosition(in: previewFrame, with: 0.2)
            
            // For more precise track roll and yaw we need to increase the Vision revision number
            if let roll = result.first?.roll {
                notRolled.value = abs(roll.floatValue) < 0.1
            }
            if let yaw = result.first?.yaw {
                notYawed.value = abs(yaw.floatValue) < 0.1
            }
            
            let rightEye = result.compactMap { $0.landmarks?.rightEye }
            if let rightEyeHeight = eyeHeight(result, rightEye),
               rightEyeHeight < 0.045 { // Just experimental value
                rightEyePoints = rightEye.flatMap { $0.normalizedPoints }.map { $0.transform(to: faceRect) }
            } else {
                rightEyePoints.removeAll()
            }
            
            let leftEye = result.compactMap { $0.landmarks?.leftEye }
            if let leftEyeHeight = eyeHeight(result, leftEye),
               leftEyeHeight < 0.045 { // Just experimental value
                leftEyePoints = leftEye.flatMap { $0.normalizedPoints }.map { $0.transform(to: faceRect) }
            } else {
                leftEyePoints.removeAll()
            }
            
            eyesIsOpen.value = rightEyePoints.isEmpty && leftEyePoints.isEmpty
            
            haveFaceRect.value = faceRect
        }
    }
    
    private func eyeHeight(_ result: [VNFaceObservation], _ eye: [VNFaceLandmarkRegion2D]) -> CGFloat? {
        let points = eye.flatMap { $0.normalizedPoints }
        guard let minY = points.map({ $0.y }).min(),
              let maxY = points.map({ $0.y }).max() else { return nil }
        return (maxY - minY) / maxY
    }
}

extension FaceDetectionVM: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
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
            let ciImage = CIImage(cvImageBuffer: cvBuffer)
            let uiImage = UIImage(ciImage: ciImage)

            self.didClose.value = true
            DispatchQueue.main.async {
                self.callback(.success(uiImage))
            }
        }
    }
}
