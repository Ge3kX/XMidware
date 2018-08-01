//
//  TetrisError.swift
//  Tetris
//
//  Created by 王俊仁 on 2018/5/4.
//

import Foundation

public protocol IErrorInfo {
    var domain: String {get}
    var code: Int {get}
    var info: [String: Any]? {get}
}

public typealias TetrisErrorable = (IErrorInfo & Error)

public enum TetrisError : TetrisErrorable {
    case error(domain: String, code: Int, info: [String: Any]?)

    public var domain: String {
        switch self {
        case .error(domain: let domain, code: _, info: _):
            return domain
        }
    }

    public var code: Int {
        switch self {
        case .error(domain: _, code: let code, info: _):
            return code
        }
    }

    public var info: [String: Any]? {
        switch self {
        case .error(domain: _, code: _, info: let info):
            return info
        }
    }
}
