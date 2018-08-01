//
//  Intercepter.swift
//  Tetris
//
//  Created by 王俊仁 on 2018/4/29.
//

import Foundation

// MARK: - IntercepterPriority
public enum IntercepterPriority: Int, Prioritable {
    public var priority: Int { return self.rawValue }
    case low = 1000
    case normal = 5000
    case high = 10000
}

// MARK: - IntercepterAdjudgement
public protocol IJudger {
    var source: UIViewController? {get}
    func getIntent() -> Intent
    func doSwitch(_ intent: Intent)
    func doReject(_ error: Error)
    func doContinue()
}


// MARK: - IIntercepter
public protocol IIntercepter {

    var priority: Prioritable {get}

    func doAdjudgement(_ judger: IJudger)
}


open class IntercepterAdaptor: IIntercepter {
    public required init() {}
    open var priority: Prioritable { return IntercepterPriority.low }
    open func doAdjudgement(_ judger: IJudger) {
        judger.doContinue()
    }
}
open class HighPriorityIntercepter: IntercepterAdaptor {
    open override var priority: Prioritable {return IntercepterPriority.high}
}
open class NormalPriorityIntercepter: IntercepterAdaptor {
    open override var priority: Prioritable {return IntercepterPriority.normal}
}
open class LowPriorityIntercepter: IntercepterAdaptor {
    open override var priority: Prioritable {return IntercepterPriority.low}
}

// MARK: - FinalIntercepter
public protocol IFinalIntercepter : class {
    static func finalAdjugement(_ judger: IJudger)
}

// MARK: - IntercepterResult
public class IntercepterResult {
    public enum Status: Int {
        case passed
        case switched
        case rejected
    }

    public var status: Status = .passed

    public var intent: Intent!

    public var error: Error?

    public var intercepter: IIntercepter?

    public init(status: Status, intent: Intent, error: Error? = nil, intercepter: IIntercepter? = nil) {
        self.status = status
        self.intent = intent
        self.intercepter = intercepter
        self.error = error
    }
}

// MARK: - IntercepterManager
public class IntercepterManager {

    var intercepters = [IIntercepter]()

    public func add(_ interceter: IIntercepter) {
        if let index = intercepters.index(where: {return $0.priority.priority < interceter.priority.priority}) {
            intercepters.insert(interceter, at: index)
        } else {
            intercepters.append(interceter)
        }
    }

    public func run(_ intent: Intent, source: UIViewController?, finish: @escaping (IntercepterResult) -> Void) {
        _run(intent, source: source, intercepters: self.intercepters, index: 0, finish: finish)
    }

    func _run(_ intent: Intent, source: UIViewController?, intercepters: [IIntercepter], index: Int, finish: @escaping (IntercepterResult) -> Void) {


        let getJudger: () -> IJudger = {
            IntercepterJudger.init(intent: intent, source: source, continued: {
                self._run(intent, source: source, intercepters: intercepters, index: index + 1, finish: finish)
            }, switched: { next in
                finish(IntercepterResult.init(status: .switched, intent: next, error: nil))
            }) { (error) in
                finish(IntercepterResult.init(status: .rejected, intent: intent, error: error, intercepter: intercepters[index]))
            }
        }

        if index == intercepters.count
            , let target = intent.target as? IFinalIntercepter.Type {
            // execute final adjugement
            target.finalAdjugement(getJudger())
        } else if index < intercepters.count {
            // execute intercepter adjugement
            intercepters[index].doAdjudgement(getJudger())
        } else {
            finish(IntercepterResult.init(status: .passed, intent: intent, error: nil))
        }

    }
}


// MARK: - IntercepterJudger

class IntercepterJudger: IJudger {

    var continueFlag = false
    var rejectedFlag = false
    var switchedFlag = false

    func checkStart() {
        assert(!continueFlag && !rejectedFlag && !switchedFlag, "you have call [doContinue] or [doReject] or [doSwitch]: \(self)")
    }

    func getIntent() -> Intent {
        return sourceIntent
    }

    func doSwitch(_ intent: Intent) {
        checkStart()
        switchedFlag = true
        switched(intent)
    }

    func doReject(_ error: Error) {
        checkStart()
        rejectedFlag = true
        reject(error)
    }

    func doContinue() {
        checkStart()
        continueFlag = true
        continued()
    }

    deinit {
        assert(rejectedFlag || continueFlag || switchedFlag, "you should call [doSwitch] or [doReject] or [doContinue]: \(self)")
    }

    var source: UIViewController?
    var sourceIntent: Intent!


    let continued: (() -> Void)!
    let switched: ((Intent) -> Void)!
    let reject: ((Error) -> Void)!

    init(intent: Intent, source: UIViewController?, continued: @escaping ()->Void, switched: @escaping (Intent)-> Void, rejected: @escaping (Error)->Void) {
        self.sourceIntent = intent
        self.source = source
        self.continued = continued
        self.switched = switched
        self.reject = rejected
    }


}


