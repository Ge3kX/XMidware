//
//  Global.swift
//  Tetris
//
//  Created by 王俊仁 on 2018/4/28.
//

import Foundation

// MARK: - Global initialization

var globalModuler: Moduler!
var globalRouter: Router!
var globalServer: Server!

public func start(moduler: Moduler? = Moduler.default,
                  router: Router? = Router.default,
                  server: Server? = Server.default) {
    globalRouter = router
    globalModuler = moduler
    globalServer = server
    TetrisAwaker.awake()
}

public func getModuler() -> Moduler {
    return globalModuler
}

public func getRouter() -> Router {
    return globalRouter
}

public func getServer() -> Server {
    return globalServer
}

public typealias IComponent = (Awakable & Initializable)

public typealias IModuleComponent = (IComponent)
public extension Awakable where Self : AbstractModule {
    public static func tetrisAwake() {
        getModuler().register(Self.init())
    }
}

public typealias IRouterComponent = (URLRoutable & IComponent)
public extension Awakable where Self : Intentable, Self : URLRoutable, Self : UIViewController {
    static func tetrisAwake() {
        getRouter().register(self.routableURL, type: Self.self)
    }
}

public typealias IIntercepterComponent = (IIntercepter & IComponent)
public extension Awakable where Self : IIntercepter, Self : Initializable {
    static func tetrisAwake() {
        getRouter().intercepterMgr.add(Self.init())
    }
}

public typealias IServiceComponent = (IService & IComponent)
public extension Awakable where Self : IService {
    static func tetrisAwake() {
        let p = serviceProfile()
        config(p)
        let servicer = getServer()
        p.servicer = servicer
        servicer.register(p)
    }
}

public typealias IActionComponent = (IRouterAction & IComponent)
public extension Awakable where Self : IRouterAction, Self : Initializable {
    static func tetrisAwake() {
        getRouter().register(action: Self.init())
    }
}






// MARK: - OC bridge
