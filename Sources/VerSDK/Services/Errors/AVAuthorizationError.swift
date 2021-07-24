import Foundation

public enum AVAuthorizationError: LocalizedError {
    case notAuthorized
    case authorizationDenied
    case authorizationRestricted

    public var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Don't authorized camera permissions"
        case .authorizationDenied:
            return "Camera permissions authorization denied"
        case .authorizationRestricted:
            return "Camera permissions authorization restricted"
        }
    }
}
