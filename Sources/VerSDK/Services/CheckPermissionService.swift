import AVFoundation

protocol CheckPermissionServiceProtocol {
    func checkPermissions(completion: @escaping (Result<Void, Error>) -> ())
}

public struct CheckPermissionsService: CheckPermissionServiceProtocol {
    public func checkPermissions(completion: @escaping (Result<Void, Error>) -> ()) {
        // Check authorization status
        let authorizationStatus =  AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch authorizationStatus {
          case .authorized:
            completion(.success(()))
          case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { authorized in
                if authorized {
                    completion(.success(()))
                } else { completion(.failure(AVAuthorizationError.notAuthorized)) }
            })
        case .denied:
            completion(.failure(AVAuthorizationError.authorizationDenied))
        case .restricted:
            completion(.failure(AVAuthorizationError.authorizationRestricted))
        default:
            completion(.failure(AVAuthorizationError.notAuthorized))
        }
    }
}
