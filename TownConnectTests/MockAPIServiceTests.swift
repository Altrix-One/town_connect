import XCTest
@testable import TownConnect

final class MockAPIServiceTests: XCTestCase {
    func testSeededUsersContainJay() async throws {
        let api = MockAPIService()
        let users = await api.getAllUsers()
        XCTAssertGreaterThanOrEqual(users.count, 1)
        XCTAssertTrue(users.contains(where: { $0.username == "jay" }))
    }
}
