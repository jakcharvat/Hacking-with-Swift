/// A rendered template.
public struct View: Codable {
    /// The view's raw data.
    public let data: Data

    /// Create a new `View`.
    public init(data: Data) {
        self.data = data
    }

    /// See `Encodable`
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(data)
    }

    /// See `Decodable`.
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        try self.init(data: container.decode(Data.self))
    }
}
