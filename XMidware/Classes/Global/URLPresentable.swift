//
//  URLPresentable.swift
//  Tetris
//
//  Created by 王俊仁 on 2018/5/9.
//

import Foundation

public protocol URLPresentable {
    func toURL() throws -> URL
}

extension String : URLPresentable {
    public func toURL() throws -> URL {
        if let url = URL.init(string: self) {
            return url
        }
        throw TetrisError.error(domain: "url convert fail", code: 2000, info: nil)
    }
}

extension URL : URLPresentable {
    public func toURL() throws -> URL {
        return self
    }
}
