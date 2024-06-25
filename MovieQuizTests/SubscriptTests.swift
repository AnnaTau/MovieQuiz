import XCTest

final class SubscriptTests: XCTestCase {
    let array = [1, 1, 2, 3, 5]
    func testSubscriptNotNil() throws {
        XCTAssertEqual(array[safe: 2], 2)
    }
    
    func testSubscriptNil() throws {
        XCTAssertNil(array[safe: 7])
    }
}

extension Array {
    subscript(safe index: Index) -> Element? {
        indices ~= index ? self[index] : nil
    }
}
