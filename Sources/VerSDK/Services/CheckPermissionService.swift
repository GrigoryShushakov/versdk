import AVFoundation

protocol CheckPermissionServiceProtocol {
    func checkPermissions(completion: @escaping (Result<Void, Error>) -> ())
}

struct CheckPermissionsService: CheckPermissionServiceProtocol {
    func checkPermissions(completion: @escaping (Result<Void, Error>) -> ()) {
        // Check camera authorization status
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
