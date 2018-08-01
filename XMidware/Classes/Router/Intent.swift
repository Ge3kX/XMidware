//
//  File.swift
//  Tetris
//
//  Created by 王俊仁 on 2018/4/28.
//

import Foundation

public protocol Intentable {
    var sourceIntent: Intent? {get set}
}

public protocol ResultReceivable {
    func didReceive<T>(resp: T?, response respCode: Int);
}

public typealias ResultBlock<T> = (T?) -> Void

public typealias IntentTargetable = (Intentable & Initializable)

public class Intent {
    

    public var target: IntentTargetable.Type?
    public var url: URLPresentable?
    public var params = [String : Any]()
    public var displayer: IDisplayer?

    private lazy var response: Response = Response()

    public internal(set) var scheme: String?
    public internal(set) var host: String?
    public internal(set) var port: Int?
    public internal(set) var path: String?
    public internal(set) var query: String?
    public internal(set) var fragment: String?

    // MARK: initializer

    public init(url: URLPresentable? = nil, target: IntentTargetable.Type? = nil) {
        self.target = target
        self.url = url
    }

    public init() {}


    // MARK: - public functions

    public func add(_ param: Any, for key: String) {
        params[key] = param
    }

    public func add(_ params: [String: Any]) {
        self.params.merge(params, uniquingKeysWith: {$1})
    }


    // MARK: - deallocating
    deinit {
        response.sendResult()
    }
}

// MARK: - Result and signal

public extension Intent {

    // MARK: - result
    public func _onResult<Result>(code: Int, resp: @escaping ResultBlock<Result>) {
        response.addResultHandler(resp, for: code)
    }

    public func _send<T>(result: T?, response respCode: Int = 0) {
        response.setupResult { (receiver) in
            receiver?.didReceive(resp: result, response: respCode)
        }
    }

    // MARK: - signal
    public func _onSignal<T>(_ signal: @escaping (T?) -> Void) {
        response.setupSignal(signal)
    }

    public func _send<T>(signal: T?) {
        response.post(signal: signal)
    }
}

// MARK: - Response

class Response: ResultReceivable {

    private var receiveAction: Any?

    private var resultCasts = [Int:Any]()

    private var signalCasts = [String:Any]()

    private var action: ((ResultReceivable?) -> Void)?

    // 最后发送
    func setupResult(_ block: @escaping (ResultReceivable?) -> Void) {
        self.action = block
    }

    // 设置处理
    func addResultHandler<T>(_ action: @escaping ResultBlock<T>, for code: Int = 0) {
        resultCasts.merge([code: Broadcast<T>()], uniquingKeysWith: {a, b in
            let ta = type(of: a)
            let tb = type(of: b)
            if ta != tb {
                print("error: you have handle code: \(code) with type: \(ta), cannot handle another type with \(tb)!!!!")
                fatalError()
            }
            return a
        })
        if let cast = resultCasts[code] {
            (cast as? Broadcast<T>)?.listening({ (ret) in
                action(ret)
            })
        }
    }

    func didReceive<T>(resp: T?, response respCode: Int) {
        (resultCasts[respCode] as? Broadcast<T>)?.post(resp)
    }

    func sendResult() {
        action?(self)
    }

    func setupSignal<T>(_ signal: @escaping (T?) -> Void) {
        let key = "\(T.self)"
        signalCasts.merge([key : Broadcast<T>()], uniquingKeysWith: {a,b in
            return a
        })
        if let cast = signalCasts[key] as? Broadcast<T> {
            cast.listening { (ret) in
                signal(ret)
            }
        }
    }

    func post<T>(signal: T?) {
        if let cast = signalCasts["\(T.self)"] as? Broadcast<T> {
            cast.post(signal)
        }
    }

}


