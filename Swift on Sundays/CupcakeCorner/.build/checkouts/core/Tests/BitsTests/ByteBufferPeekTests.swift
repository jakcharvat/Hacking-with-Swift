import NIO
import XCTest
@testable import Bits

final class ByteBufferPeekTests: XCTestCase {
    private let allocator = ByteBufferAllocator()
    private var buf: ByteBuffer! = nil

    func testPeekFixedWidthInteger() {
        buf = allocator.buffer(capacity: 32)
        let first: Int = 1
        let second: Int = 3
        buf.write(integer: first)
        buf.write(integer: second)
        XCTAssertEqual(buf.peekInteger(skipping: 0), first)
        XCTAssertEqual(buf.peekInteger(skipping: MemoryLayout<Int>.size), second)
    }

    func testPeekString() {
        buf = allocator.buffer(capacity: 256)
        let first = "My String"
        let second = "My other string"

        buf.write(string: first)
        buf.write(string: second)

        XCTAssertEqual(buf.peekString(length: first.count, encoding: .utf8), first)
        XCTAssertEqual(buf.peekString(length: second.count,
                                      skipping: first.count,
                                      encoding: .utf8), second)

        _ = buf.readBytes(length: first.count)
        XCTAssertEqual(buf.peekString(length: second.count,
                                      encoding: .utf8), second)
    }

    func testPeekData() {
        buf = allocator.buffer(capacity: 256)
        let first = Array("My String".utf8)
        let second = Array("My other string".utf8)

        buf.write(bytes: first)
        buf.write(bytes: second)

        XCTAssertEqual(buf.peekData(length: first.count), Data(bytes: first))
        XCTAssertEqual(buf.peekData(length: second.count,
                                    skipping: first.count), Data(bytes: second))

        _ = buf.readBytes(length: first.count)
        XCTAssertEqual(buf.peekData(length: second.count), Data(bytes: second))
    }

    func testPeekBinaryFloatingPoint() throws {
        buf = allocator.buffer(capacity: 32)
        let first: Double = 9.42
        let second: Float = 9.43212

        buf.write(floatingPoint: first)
        buf.write(floatingPoint: second)

        XCTAssertEqual(buf.peekFloatingPoint(as: Double.self), first)
        XCTAssertEqual(buf.peekFloatingPoint(skipping: MemoryLayout<Double>.size,
            as: Float.self), second)


        XCTAssertEqual(try buf.requireReadFloatingPoint(as: Double.self), first)

        XCTAssertEqual(buf.peekFloatingPoint(as: Float.self), second)
    }

    func testPeekBytes() {
        buf = allocator.buffer(capacity: 128)
        let byte1 = UInt8(1)
        let byte2 = UInt8(2)
        buf.write(bytes: [byte1, byte2])

        let peekedBytes = buf.peekBytes(count: 2)
        XCTAssertEqual(peekedBytes?.first, byte1)
        XCTAssertEqual(peekedBytes?.last, byte2)
        XCTAssertEqual(buf.readBytes(length: 1)?.first, byte1)
        XCTAssertEqual(buf.peekBytes(count: 1)?.first, byte2)
        XCTAssertEqual(buf.peekBytes(count: 2), nil)
    }

    func testPeekFirstByte() {
        buf = allocator.buffer(capacity: 128)
        let byte1 = UInt8(1)
        let byte2 = UInt8(2)
        buf.write(bytes: [byte1, byte2])

        XCTAssertEqual(buf.peekInteger(as: Byte.self), byte1)
        XCTAssertEqual(buf.readBytes(length: 1)?.first, byte1)
        XCTAssertEqual(buf.peekInteger(as: Byte.self), byte2)

        XCTAssertEqual(buf.readBytes(length: 1)?.first, byte2)
        XCTAssertEqual(buf.peekInteger(as: Byte.self), nil)
    }

    static let allTests = [
        ("testPeekFixedWidthInteger", testPeekFixedWidthInteger),
        ("testPeekString", testPeekString),
        ("testPeekData", testPeekData),
        ("testPeekBinaryFloatingPoint", testPeekBinaryFloatingPoint),
    ]
}
