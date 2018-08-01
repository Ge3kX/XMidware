//
//  ServiceProfile.swift
//  Tetris
//
//  Created by 王俊仁 on 2018/5/3.
//

import Foundation

// MARK: - IService

public protocol IService {
    associatedtype Interface
    static func serviceProfile() -> ServiceProfile<Interface>
    static func config(_ profile: ServiceProfile<Interface>)
}

public extension IService where Self : Initializable {
    static func serviceProfile() -> ServiceProfile<Interface> {
        return ServiceProfile.init(Interface.self, impl: Self.self)
    }
}


// MARK: - ServiceProfile

public class ServiceProfile<Interface> {

    var name: String? = nil
    var singleton: Bool = false
    lazy var singletonInstance: Interface = generate()
    var implType: Initializable.Type!
    var interfaceType: Interface.Type!
    var awake: (Server, Interface) -> Void = {_, _ in}

    weak var servicer: Server?

    public init(_ interface: Interface.Type, impl: Initializable.Type) {
        self.implType = impl
        self.interfaceType = interface
    }

    // MARK: methods
    func getService() -> Interface {
        if singleton {
            return singletonInstance
        } else {
            return generate()
        }
    }

    func generate() -> Interface {
        let impl = implType.init()
        if let servicer = servicer {
            awake(servicer, impl as! Interface)
        }
        return impl as! Interface
    }

    // MARK: - public methods

    @discardableResult
    public func setAwake(_ awake: @escaping (Server, Interface) -> Void) -> Self {
        self.awake = awake
        return self
    }

    @discardableResult
    public func setName(_ name: String) -> Self {
        self.name = name
        return self
    }

    @discardableResult
    public func setSingle() -> Self {
        self.singleton = true
        return self
    }


}
