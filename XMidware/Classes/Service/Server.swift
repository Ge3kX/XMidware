//
//  Servicer.swift
//  Tetris
//
//  Created by 王俊仁 on 2018/5/2.
//

import Foundation



public class Server {

    public init() {}
    public static let `default` = Server()

    var serviceTree = Tree()

    let namePrefix = "name"
    let typePrefix = "type"

    private func getName(with type: Any.Type) -> String {
        return "\(type.self)"
    }

    public func register<Interface>(_ profile: ServiceProfile<Interface>) {
        if let name = profile.name {
            let np = NodePath.init(path: [namePrefix, name], value: profile)
            serviceTree.buildTree(nodePath: np)
        } else {
            let key = getName(with: profile.interfaceType)
            let np = NodePath.init(path: [typePrefix, key], value: profile)
            serviceTree.buildTree(nodePath: np)
        }
    }

    public func get<Interface>(_ name: String? = nil) -> Interface? {
        if let name = name,
            let findResult = serviceTree.findNode(by: [namePrefix, name]) {
            let profile: ServiceProfile<Interface>? = findResult.1.getValue()
            return profile?.getService()
        } else if let findResult = serviceTree.findNode(by: [typePrefix, getName(with: Interface.self)]) {
            let profile: ServiceProfile<Interface>? = findResult.1.getValue()
            return profile?.getService()
        }
        return nil
    }

}

