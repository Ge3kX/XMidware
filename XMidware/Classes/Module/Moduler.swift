//
//  Module.swift
//  Tetris
//
//  Created by 王俊仁 on 2018/4/28.
//

import Foundation

// MARK: - Moduler
public class Moduler {

    public init() {}

    public static let `default` = Moduler()

    var modules: [AbstractModule] = [AbstractModule]()

    public func register(_ module: AbstractModule) {
        let priority = module.priority
        let index = modules.index { $0.priority.priority < priority.priority }
        if let idx = index {
            modules.insert(module, at: idx)
        } else {
            modules.append(module)
        }
    }

    public func trigger(_ action: (AbstractModule) -> (Context) -> Void) {
        modules.enumerated().forEach { (idx, module) in
            action(module)(Context.shared)
        }
    }

    public func trigger(event: Int, userInfo: [String: Any] = [String: Any]()) {
        modules.enumerated().forEach { (idx, module) in
            module.modulerDidTrigger(event, userInfo: userInfo)
        }
    }


}
