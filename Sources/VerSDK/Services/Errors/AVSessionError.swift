import Foundation

public enum AVSessionError: LocalizedError {
    case deviceInitFailure(String)
    case deviceInputInitFailure(String)
    case addInputToSessionFailure(String)
    case addOutputToSessionFailure
    
    public var errorDescription: String? {
        switch self {
        case .deviceInitFailure(let key):
            return "Device initialization failure: \(key)"
        case .deviceInputInitFailure(let key):
            return "Device input initialization failure: \(key)"
        case .addInputToSessionFailure(let key):
            return "Could not add input to capture session: \(key)"
        case .addOutputToSessionFailure:
            return "Could not add output to capture session."
        }
    }
}
