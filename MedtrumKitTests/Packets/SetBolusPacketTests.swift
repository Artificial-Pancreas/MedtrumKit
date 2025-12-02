@testable import MedtrumKit
import XCTest

final class SetBolusPacketTests: XCTestCase {
    func testRequestGivenPacketWhenValuesSetThenReturnCorrectByteArray() throws {
        let input = SetBolusPacket(bolusAmount: 1.40)

        let expected = Data([9, 19, 0, 0, 1, 28, 0, 0, 253, 0])

        let sequence: UInt8 = 0
        let actual = input.encode(sequenceNumber: sequence)

        XCTAssertEqual(actual.count, 1)
        XCTAssertEqual(actual[0], expected)
    }
}
