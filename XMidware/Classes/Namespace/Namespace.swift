//
//  Namespace.swift
//  Tetris
//
//  Created by 王俊仁 on 2018/4/28.
//

import Foundation


public final class _TetrisNamespaceWrapper<Subject> {
    let subject: Subject
    public init(_ subject: Subject) {
        self.subject = subject
    }
}

// MARK: - Test namespacing


public protocol TetrisNamespacing {
    associatedtype Wrappable
    var ts: Wrappable {get}
    static var ts: Wrappable.Type {get}
}

public extension TetrisNamespacing {
    public var ts: _TetrisNamespaceWrapper<Self> {
        return _TetrisNamespaceWrapper(self)
    }

    public static var ts : _TetrisNamespaceWrapper<Self>.Type {
        return _TetrisNamespaceWrapper<Self>.self
    }
}


