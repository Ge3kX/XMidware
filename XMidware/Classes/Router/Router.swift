//
//  Router.swift
//  Pods-Tetris_Example
//
//  Created by 王俊仁 on 2018/4/28.
//

import Foundation

public class Router {

    var viewTree = Tree()

    var actionTree = Tree()

    var broadTree = Tree()

    public init() {}

    public static let `default` = Router()

    public let intercepterMgr = IntercepterManager()

}


// MARK: - View Registery

public protocol URLRoutable {
    static var routableURL: URLPresentable {get}
}

// MARK: - View Action

public enum RouterError: TetrisErrorable {

    case routeLost(intent: Intent)

    public var domain: String {return "Router lost!!"}

    public var code: Int {return 3000}

    public var info: [String : Any]? {
        switch self {
        case .routeLost(intent: _):
            return nil
        }
    }


}

public extension Router {

    public func register(_ url: URLPresentable, type: Intentable.Type) {

        guard let result = URLResult.init(url: url) else {
            return
        }
        viewTree.buildTree(nodePath: NodePath.init(path: result.paths, value: type))
    }

    public func prepare(_ intent: Intent, source: UIViewController? = nil, completion: IDisplayer.Completion? = nil) -> Delivery<RouteResult> {
        return Delivery<RouteResult>.init({ (p) in
            self.start(intent, source: source, completion: completion, finish: { (result) in
                if let err = result.error {
                    p.package(result, error: err)
                } else {
                    p.package(result, error: nil)
                }
            })
            return nil
        })
    }

    public func start(_ intent: Intent, source: UIViewController? = nil, completion: IDisplayer.Completion? = nil, finish: @escaping (RouteResult) -> Void) {
        _start(intent, source: source, switched: false, completion: completion, finish: finish)
    }

    public func _start(_ intent: Intent,
                       source: UIViewController?,
                       switched: Bool,
                       completion: IDisplayer.Completion?,
                       finish: @escaping (RouteResult) -> Void) {
        build(intent: intent)
        intercepterMgr.run(intent, source: source) { (result) in
            switch result.status {
            case .switched:
                self._start(result.intent, source: source, switched: true, completion: completion, finish: finish)
            case .rejected:
                finish(RouteResult.init(status: .rejected, intent: result.intent, destination: nil, error: result.error))
            case .passed:
                if let target = intent.target {

                    var destination = target.init()

                    destination.sourceIntent = intent

                    // start transioning
                    if let source = source, let displayer = intent.displayer {

                        self.transitioning(destination, source: source, displayer: displayer, completion: completion)
                    }
                    finish(RouteResult.init(status: switched ? .switched : .passed, intent: intent, destination: destination as? UIViewController))
                } else {
                    // on lost
                    finish(RouteResult.init(status: .lost, intent: intent, destination: nil, error: RouterError.routeLost(intent: intent)))
                }
            }
        }
    }

    func build(intent: Intent) {
        if let url = intent.url, intent.target == nil {
            let result = URLResult.init(url: url)
            if let result = result, let findResult = viewTree.findNode(by: result.paths) {
                intent.add(findResult.0)
                intent.add(result.params)
                intent.scheme = result.scheme
                intent.host = result.host
                intent.port = result.port
                intent.path = result.path
                intent.fragment = result.fragment
                intent.query = result.query
                intent.target = findResult.1.getValue()
            }
        }
    }

    func transitioning(_ intentable: Intentable,
                       source: UIViewController,
                       displayer: IDisplayer,
                       completion: IDisplayer.Completion?) -> Void {

        guard let target = intentable as? UIViewController else {
            return
        }
        displayer.display(from: source, to: target, animated: true, complete: completion)
    }

}


// MARK: - RouteResult
public class RouteResult {
    public enum Status: Int {
        case passed
        case switched
        case rejected
        case lost
    }

    public var destination: UIViewController?
    public var intent: Intent
    public var error: Error?
    public var status: Status

    public init(status: Status, intent: Intent, destination: UIViewController? = nil, error: Error? = nil) {
        self.destination = destination
        self.status = status
        self.intent = intent
        self.error = error
    }
}

// MARK: - Actions

public protocol IRouterAction {
    associatedtype Result
    func routerAction(params: [String: Any], fragment: String?) -> Delivery<Result>
    var actionURL: URLPresentable {get}
}

class ActionHelper<T>: IRouterAction {
    
    var actionURL: URLPresentable
    typealias Result = T


    func routerAction(params: [String : Any], fragment: String?) -> Delivery<T> {
        if let next = nextAction {
            return next(params, fragment)
        }
        return Delivery.init({ (p) in
            self.action?(params, fragment, p)
            return nil
        })
    }

    var action: (([String: Any], String?, Packager<T>) -> Void)?

    var nextAction: (([String: Any], String?) -> Delivery<T>)?


    init(url: URLPresentable, block: @escaping ([String: Any], String?, Packager<T>) -> Void) {
        self.action = block
        self.actionURL = url
    }

    init<Action: IRouterAction>(_ action: Action) where Action.Result == T {
        self.nextAction = action.routerAction
        self.actionURL = action.actionURL
    }
}


public extension Router {

    public typealias RouterAction<T> = ([String: Any], String?, Packager<T>) -> Void

    public func register<Result>(_ url: URLPresentable, action: @escaping RouterAction<Result>) {
        if let result = URLResult.init(url: url) {
            let path = NodePath.init(path: result.paths, value: ActionHelper.init(url: url, block: action))
            actionTree.buildTree(nodePath: path)
        }
    }

    public func register<Action: IRouterAction>(action: Action)  {
        if let result = URLResult.init(url: action.actionURL) {
            let path = NodePath.init(path: result.paths, value: ActionHelper.init(action))
            actionTree.buildTree(nodePath: path)
        }
    }

    public func action<Result>(_ url: URLPresentable, params: [String : Any] = [:]) -> Delivery<Result> {

        let result = URLResult.init(url: url)

        if let result = result,
            let nodeRet = actionTree.findNode(by: result.paths),
            let action: ActionHelper<Result> = nodeRet.1.getValue() {
            var parameters = params
            result.params.forEach { (key, value) in
                parameters[key] = value
            }
            return action.routerAction(params: parameters, fragment: result.fragment)
        } else {
            return Delivery.error(TetrisError.error(domain: "can not find action!!!", code: 1000, info: nil))
        }
    }

}

// MARK: - Broadcast

extension Router {

    public func register(_ url: URLPresentable, broadcast: Broadcast<[String: Any]>) {
        if let result = URLResult.init(url: url) {
            let path = NodePath.init(path: result.paths, value: broadcast)
            broadTree.buildTree(nodePath: path)
        }
    }

    public func broadcast(_ url: URLPresentable) -> Broadcast<[String: Any]>? {
        if let result = URLResult.init(url: url),
            let findResult = broadTree.findNode(by: result.paths),
            let broadcast: Broadcast<[String: Any]> = findResult.1.getValue() {
            return broadcast
        }
        return nil
    }
}

// MARK: - URLResult

public struct URLResult {

    public var value: Any?

    public var params: [String:String] = [String:String]()

    public private(set) var url: URLPresentable

    public private(set) var scheme: String?

    public private(set) var host: String?

    public private(set) var port: Int?

    public private(set) var path: String?

    public private(set) var query: String?

    public private(set) var paths: [String] = [String]()

    public private(set) var fragment: String?

    public init?(url: URLPresentable) {
        self.url = url


        do {
            guard let com = try URLComponents(url: url.toURL(), resolvingAgainstBaseURL: false) else {
                return nil
            }

            let paths = com.path.components(separatedBy: "/").filter({$0.count > 0})

            scheme = com.scheme
            host = com.host
            path = com.path
            query = com.query
            port = com.port

            var params = [String:String]()

            com.queryItems?.forEach({ (item) in
                params[item.name] = item.value
            })

            self.params = params
            self.fragment = com.fragment
            self.paths = paths
        } catch {
            print("error: \(error)!!!")
            return nil
        }

    }

}
