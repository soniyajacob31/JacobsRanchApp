//
//  AnyEncodable.swift
//  JacobsRanchApp
//

import Foundation

public struct AnyEncodable: Encodable {
    private let encodeFunc: (Encoder) throws -> Void

    public init<T: Encodable>(value: T) {
        self.encodeFunc = value.encode
    }

    public func encode(to encoder: Encoder) throws {
        try encodeFunc(encoder)
    }
}
