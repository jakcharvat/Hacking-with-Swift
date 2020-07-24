import Crypto

/// Represents a client connected via WebSocket protocol.
/// Use this to receive text/data frames and send responses.
///
///      ws.onText { ws, string in
///         ws.send(string.reversed())
///      }
///
public final class WebSocket: BasicWorker {
    /// Available WebSocket modes. Either `Client` or `Server`.
    internal enum Mode {
        
        /// Uses socket in `Client` mode
        case client
        
        /// Uses socket in `Server` mode
        case server
        
        /// RFC 6455 Section 5.1
        /// To avoid confusing network intermediaries (such as intercepting proxies) and
        /// for security reasons that are further, a client MUST mask all frames that it
        /// sends to the server.
        /// The server MUST close the connection upon receiving a frame that is not masked.
        /// A server MUST NOT mask any frames that it sends to the client.
        /// A client MUST close a connection if it detects a masked frame.
        ///
        /// RFC 6455 Section 5.3
        /// The masking key is a 32-bit value chosen at random by the client.
        /// When preparing a masked frame, the client MUST pick a fresh masking
        /// key from the set of allowed 32-bit values.
        internal func makeMaskKey() -> WebSocketMaskingKey? {
            switch self {
            case .client:
                let buffer = try? CryptoRandom().generateData(count: 4).map { $0 }
                return buffer.flatMap(WebSocketMaskingKey.init)
            case .server:
                return  nil
            }
        }
    }
    
    /// See `BasicWorker`.
    public var eventLoop: EventLoop {
        return channel.eventLoop
    }

    /// Outbound `WebSocketEventHandler`.
    private let channel: Channel
    
    /// `WebSocket` processing mode.
    internal let mode: Mode

    /// See `onText(...)`.
    var onTextCallback: (WebSocket, String) -> ()
    
    /// Buffers text frames we get before a handler is connected
    private var textBuffer: [String]?

    /// See `onBinary(...)`.
    var onBinaryCallback: (WebSocket, Data) -> ()
    
    /// Buffers data frames we get before a handler is connected
    private var binaryBuffer: [Data]?

    /// See `onError(...)`.
    var onErrorCallback: (WebSocket, Error) -> ()
    
    /// Buffers error frames we get before a handler is connected
    private var errorBuffer: [Error]?

    /// See `onCloseCode(...)`.
    var onCloseCodeCallback: (WebSocketErrorCode) -> ()

    /// Creates a new `WebSocket` using the supplied `Channel` and `Mode`.
    /// Use `httpProtocolUpgrader(...)` to create a protocol upgrader that can create `WebSocket`s.
    internal init(channel: Channel, mode: Mode) {
        self.channel = channel
        self.mode = mode
        self.isClosed = false
        self.onTextCallback = { _, _ in }
        self.onBinaryCallback = { _, _ in }
        self.onErrorCallback = { _, _ in }
        self.onCloseCodeCallback = { _ in }
        
        self.onTextCallback = { [unowned self] _, text in
            guard self.textBuffer != nil else {
                self.textBuffer = [text]
                return
            }
            self.textBuffer?.append(text)
        }
        self.onBinaryCallback = { [unowned self] _, binary in
            guard self.binaryBuffer != nil else {
                self.binaryBuffer = [binary]
                return
            }
            self.binaryBuffer?.append(binary)
        }
        self.onErrorCallback = { [unowned self] _, error in
            guard self.errorBuffer != nil else {
                self.errorBuffer = [error]
                return
            }
            self.errorBuffer?.append(error)
        }
    }

    // MARK: Receive

    /// Adds a callback to this `WebSocket` to receive text-formatted messages.
    ///
    ///     ws.onText { ws, string in
    ///         ws.send(string.reversed())
    ///     }
    ///
    /// Use `onBinary(_:)` to handle binary-formatted messages.
    ///
    /// - parameters:
    ///     - callback: Closure to accept incoming text-formatted data.
    ///                 This will be called every time the connected client sends text.
    public func onText(_ callback: @escaping (WebSocket, String) -> ()) {
        onTextCallback = callback
        self.textBuffer?.forEach { onTextCallback(self, $0) }
        self.textBuffer = nil
    }

    /// Adds a callback to this `WebSocket` to receive binary-formatted messages.
    ///
    ///     ws.onBinary { ws, data in
    ///         print(data)
    ///     }
    ///
    /// Use `onText(_:)` to handle text-formatted messages.
    ///
    /// - parameters:
    ///     - callback: Closure to accept incoming binary-formatted data.
    ///                 This will be called every time the connected client sends binary-data.
    public func onBinary(_ callback: @escaping (WebSocket, Data) -> ()) {
        onBinaryCallback = callback
        self.binaryBuffer?.forEach { onBinaryCallback(self, $0) }
        self.binaryBuffer = nil
    }

    /// Adds a callback to this `WebSocket` to handle errors.
    ///
    ///     ws.onError { ws, error in
    ///         print(error)
    ///     }
    ///
    /// - parameters:
    ///     - callback: Closure to handle error's caught during this connection.
    public func onError(_ callback: @escaping (WebSocket, Error) -> ()) {
        onErrorCallback = callback
        self.errorBuffer?.forEach { onErrorCallback(self, $0) }
        self.errorBuffer = nil
    }

    /// Adds a callback to this `WebSocket` to handle incoming close codes.
    ///
    ///     ws.onCloseCode { closeCode in
    ///         print(closeCode)
    ///     }
    ///
    /// - parameters:
    ///     - callback: Closure to handle received close codes.
    public func onCloseCode(_ callback: @escaping (WebSocketErrorCode) -> ()) {
        onCloseCodeCallback = callback
    }

    // MARK: Send

    /// Sends text-formatted data to the connected client.
    ///
    ///     ws.onText { ws, string in
    ///         ws.send(string.reversed())
    ///     }
    ///
    /// - parameters:
    ///     - text: `String` to send as text-formatted data to the client.
    ///     - promise: Optional `Promise` to complete when the send is finished.
    public func send<S>(_ text: S, promise: Promise<Void>? = nil) where S: Collection, S.Element == Character {
        return send(text: String(text), promise: promise)
    }

    /// Sends binary-formatted data to the connected client.
    ///
    ///     ws.onText { ws, string in
    ///         ws.send([0x68, 0x69])
    ///     }
    ///
    /// - parameters:
    ///     - text: `Data` to send as binary-formatted data to the client.
    ///     - promise: Optional `Promise` to complete when the send is finished.
    public func send(_ binary: Data, promise: Promise<Void>? = nil) {
        return send(binary: binary, promise: promise)
    }

    /// Sends text-formatted data to the connected client.
    ///
    ///     ws.onText { ws, string in
    ///         ws.send(text: string.reversed())
    ///     }
    ///
    /// - parameters:
    ///     - text: `LosslessDataConvertible` to send as text-formatted data to the client.
    ///     - promise: Optional `Promise` to complete when the send is finished.
    public func send(text: LosslessDataConvertible, promise: Promise<Void>? = nil) {
        send(raw: text, opcode: .text, promise: promise)
    }

    /// Sends binary-formatted data to the connected client.
    ///
    ///     ws.onText { ws, string in
    ///         ws.send(binary: [0x68, 0x69])
    ///     }
    ///
    /// - parameters:
    ///     - data: `LosslessDataConvertible` to send as binary-formatted data to the client.
    ///     - promise: Optional `Promise` to complete when the send is finished.
    public func send(binary: LosslessDataConvertible, promise: Promise<Void>? = nil) {
        send(raw: binary, opcode: .binary, promise: promise)
    }
    
    /// Sends raw-data to the connected client using the supplied WebSocket opcode.
    ///
    ///     // client will receive "Hello, world!" as one message
    ///     ws.send(raw: "Hello, ", opcode: .text, fin: false)
    ///     ws.send(raw: "world", opcode: .continuation, fin: false)
    ///     ws.send(raw: "!", opcode: .continuation)
    ///
    /// - parameters:
    ///     - data: `LosslessDataConvertible` to send to the client.
    ///     - opcode: `WebSocketOpcode` indicating data format. Usually `.text` or `.binary`.
    ///     - fine: If `false`, additional `.continuation` frames are expected.
    ///     - promise: Optional `Promise` to complete when the send is finished.
    public func send(raw data: LosslessDataConvertible, opcode: WebSocketOpcode, fin: Bool = true, promise: Promise<Void>? = nil) {
        guard !isClosed else { return }
        let data = data.convertToData()
        var buffer = channel.allocator.buffer(capacity: data.count)
        buffer.write(bytes: data)
        send(buffer, opcode: opcode, fin: fin, promise: promise)
    }

    // MARK: Close

    /// `true` if the `WebSocket` has been closed.
    public internal(set) var isClosed: Bool

    /// A `Future` that will be completed when the `WebSocket` closes.
    public var onClose: Future<Void> {
        return channel.closeFuture
    }

    /// Closes the `WebSocket`'s connection, disconnecting the client.
    ///
    /// - parameters:
    ///     - code: Optional `WebSocketCloseCode` to send before closing the connection.
    ///             If a code is provided, the WebSocket will wait until an acknowledgment is
    ///             received from the server before actually closing the connection.
    public func close(code: WebSocketErrorCode? = nil) {
        guard !isClosed else {
            return
        }
        self.isClosed = true
        if let code = code {
            sendClose(code: code)
        } else {
            channel.close(promise: nil)
        }
    }

    // MARK: Private

    /// Private just send close code.
    private func sendClose(code: WebSocketErrorCode) {
        var buffer = channel.allocator.buffer(capacity: 2)
        buffer.write(webSocketErrorCode: code)
        send(buffer, opcode: .connectionClose, fin: true, promise: nil)
    }

    /// Private send that accepts a raw `WebSocketFrame`.
    private func send(_ buffer: ByteBuffer, opcode: WebSocketOpcode, fin: Bool, promise: Promise<Void>?) {
        let frame = WebSocketFrame(
            fin: fin,
            opcode: opcode,
            maskKey: mode.makeMaskKey(),
            data: buffer
        )
        channel.writeAndFlush(frame, promise: promise)
    }
}
