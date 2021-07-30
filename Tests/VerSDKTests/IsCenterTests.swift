import XCTest
@testable import VerSDK

final class IsCenterTests: XCTestCase {
    
    // Test isCenter function
    func testIsCenter() {
        let goodRect = CGRect(x: 83.0, y: 318.0, width: 262.0, height: 319.0)
        let badRect = CGRect(x: 146.0, y: 345.0, width: 246.0, height: 299.0)
        let viewRect = CGRect(x: 0, y: 0, width: 428, height: 926)
        let deviation = CGFloat(0.2)
        XCTAssertTrue(goodRect.isCenterPosition(in: viewRect, with: deviation))
        XCTAssertFalse(badRect.isCenterPosition(in: viewRect, with: deviation))
    }
}
