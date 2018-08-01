//
//  TetrisInitializable.swift
//  Tetris
//
//  Created by 王俊仁 on 2018/4/28.
//

import Foundation

public protocol Awakable {
    static func tetrisAwake()
}

public protocol Initializable {
    init()
}

class TetrisAwaker {
    
    static func awake() {
        let typeCount = Int(objc_getClassList(nil, 0))
        let types = UnsafeMutablePointer<AnyClass>.allocate(capacity: typeCount)
        let autoreleasingTypes = AutoreleasingUnsafeMutablePointer<AnyClass>(types)
        objc_getClassList(autoreleasingTypes, Int32(typeCount))
        let begin = Date.init().timeIntervalSince1970
        for index in 0 ..< typeCount {
            (types[index] as? Awakable.Type)?.tetrisAwake()
        }
        let end = Date().timeIntervalSince1970
        print("\(begin)")
        print("\(end)")
        types.deallocate()
    }
    
}
