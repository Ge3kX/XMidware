//
//  Prioritable.swift
//  Tetris
//
//  Created by J on 2018/5/11.
//

import Foundation

public protocol Prioritable {
    var priority: Int { get }
}

extension Int : Prioritable {
    public var priority: Int { return self }
}

public extension Prioritable {
    public static func + (lhs: Prioritable, rhs: Prioritable) -> Prioritable {
        return lhs.priority + rhs.priority
    }

    public static func - (lhs: Prioritable, rhs: Prioritable) -> Prioritable {
        return lhs.priority - rhs.priority
    }
}
