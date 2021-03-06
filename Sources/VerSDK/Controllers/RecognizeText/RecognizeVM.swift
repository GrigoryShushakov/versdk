import UIKit
import AVFoundation
import Vision

final class RecognizeVM: NSObject, CheckPermissionProtocol {
    var callback: ((Result<[String], Error>) -> Void)
    let captureService: CaptureSessionServiceProtocol
    var takeShot = false
    
    // Vision requests for text recognition
    private var requests = [VNRequest]()
    
    // Preview frame rect for transformations
    var previewFrame = CGRect()
    
    // Rectangles for showing detected areas, UIKit coordinates
    var boxes = [CGRect]()
    
    // Custom observables, for binding changes to ui layer
    let didClose: SimpleObservable<Bool> = SimpleObservable(false)
    let haveFoundText: SimpleObservable<Bool?> = SimpleObservable(nil)
    
    init(callback: @escaping ((Result<[String], Error>) -> Void),
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
    
    func startSession() {
        captureService.startSession(delegate: self,
                                    position: .back,
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
    
    func switchCameraInput() {
        captureService.switchCameraInput()
    }
    
    private func setupVision() {
        let textRequest = VNRecognizeTextRequest(completionHandler: self.textDetectionHandler)
        textRequest.recognitionLevel = .accurate
        textRequest.usesLanguageCorrection = false
        textRequest.recognitionLanguages = ["ee_EE", "en_US"]
        self.requests = [textRequest]
    }
    
    private func textDetectionHandler(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
        let result = observations.compactMap { $0.topCandidates(1).first?.string }
        boxes = result.isEmpty ? [] : observations.map{ $0.boundingBox }.map { $0.transform(to: previewFrame) }
        haveFoundText.value = !result.isEmpty
        
        if takeShot {
            takeShot = false
            didClose.value = true
            DispatchQueue.main.async {
                self.callback(.success(result))
            }
        }
    }
}

extension RecognizeVM: AVCaptureVideoDataOutputSampleBufferDelegate {
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
    }
}
