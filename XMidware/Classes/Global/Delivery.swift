//
//  Notice.swift
//  Tetris
//
//  Created by 王俊仁 on 2018/5/4.
//

import Foundation

public class Order<T> {

    let action: () -> Void

    var packager: Packager<T>!

    public init(_ action: @escaping () -> Void) {
        self.action = action
    }

    public func cancel() {
        packager.cancelled = true
        action()
    }

}

public class Packager<T> {

    var receiveAction: Delivery<T>.ReceiveAction!

    var cancelled: Bool = false

    public func package(_ object: T?, error: Error?) {
        if cancelled { return }
        receiveAction(object, error)
    }
}

public class Delivery<T> {

    public typealias WrapAction = (Packager<T>) -> Order<T>?
    public typealias ReceiveAction = (T?, Error?) -> Void

    var action: WrapAction!

    public init(_ action: @escaping WrapAction) {
        self.action = action
    }

    @discardableResult
    public func receive(_ receive: @escaping ReceiveAction) -> Order<T>? {
        let p = Packager<T>()
        p.receiveAction = receive
        let order = action(p)
        order?.packager = p
        return order
    }

}

// MARK: - Creations

extension Delivery {

    public static func package(_ value: T?) -> Delivery<T> {
        return Delivery.init({p in
            p.package(value, error: nil)
            return nil
        })
    }

    public static func stop() -> Delivery<T> {
        return Delivery.init({p in
            return nil
        })
    }

    public static func error(_ err: Error) -> Delivery<T> {
        return Delivery.init({p in
            p.package(nil, error: err)
            return nil
        })
    }

    public static func after(_ interval: TimeInterval) -> Delivery<T> {
        return Delivery.package(nil).delay(interval)
    }

    public static func dispatch(_ queue: OperationQueue) -> Delivery<T> {
        return Delivery.package(nil).dispatch(queue)
    }



}

// MARK: - Actions
extension Delivery {

    public func bind<U>(_ action: @escaping (T?, Error?, Packager<U>) -> Void) -> Delivery<U> {
        return Delivery<U>.init({ (p) -> Order<U>? in
            let o = self.receive({ (ret, err) in
                action(ret, err, p)
            })
            return Order.init({
                o?.cancel()
            })
        })
    }

    public func bindOnSuccess<U>(_ action: @escaping (T?, Packager<U>) -> Void) -> Delivery<U> {
        return bind({ (ret, err, p) in
            if let err = err {
                p.package(nil, error: err)
            } else {
                action(ret, p)
            }
        })
    }

    public func bindOnError<U>(_ action: @escaping (Error, Packager<U>) -> Void) -> Delivery<U> {
        return bind({ (ret, err, p) in
            if let err = err {
                action(err, p)
            } else {
                p.package(ret as? U, error: nil)
            }
        })
    }

    public func map<U>(_ action: @escaping (T?) -> U?) -> Delivery<U> {
        return bindOnSuccess({
            $1.package(action($0), error: nil)
        })
    }

    public func forceMap<U>(_ obj: U?) -> Delivery<U> {
        return map { _ in obj }
    }

    public func transform<U>(_ action: @escaping (T?) -> Delivery<U>) -> Delivery<U> {
        return bindOnSuccess({ (ret, p) in
            let d = action(ret)
            d.receive {ret, err in p.package(ret, error: err) }
        })
    }

    public func concat<U>(_ next: Delivery<U>) -> Delivery<U> {
        return transform({_ in next})
    }


    public func onNext(_ action: @escaping (T?, Error?) -> Void) -> Delivery<T> {
        return bind({
            action($0, $1)
            $2.package($0, error: $1)
        })
    }

    public func onSuccess(_ action: @escaping (T?) -> Void) -> Delivery<T> {
        return bindOnSuccess({
            action($0)
            $1.package($0, error: nil)
        })
    }

    public func onError(_ action: @escaping (Error) -> Void) -> Delivery<T> {
        return bindOnError({ (err, p) in
            action(err)
            p.package(nil, error: err)
        })
    }

    public func `catch`<U>(_ action: @escaping (Error) -> Delivery<U>) -> Delivery<U> {
        return bindOnError({ (err, p) in
            let d = action(err)
            d.receive({ (ret, error) in
                p.package(ret, error: error)
            })
        })
    }

    public func delay(_ interval: TimeInterval) -> Delivery<T> {
        return bindOnSuccess({ (ret, p) in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + interval, execute: {
                p.package(ret, error: nil)
            })
        })
    }

    public func dispatch(_ queue: OperationQueue) -> Delivery<T> {
        return bindOnSuccess({ (ret, p) in
            let o = BlockOperation.init(block: {
                p.package(ret, error: nil)
            })
            queue.addOperation(o)
        })
    }

    public func async() -> Delivery<T> {
        return dispatch(OperationQueue())
    }

    public func mainQueue() -> Delivery<T> {
        return dispatch(OperationQueue.main)
    }

    public func first(_ action: @escaping () -> Void) -> Delivery<T> {
        return Delivery.init({ (p) -> Order<T>? in
            action()
            return self.receive({ (ret, err) in
                p.package(ret, error: err)
            })
        })
    }

    public func last(_ action: @escaping () -> Void) -> Delivery<T> {
        return Delivery.init({ (p) -> Order<T>? in
            return self.receive({ (ret, err) in
                p.package(ret, error: err)
                action()
            })
        })
    }
    
    public func retry(_ maxCount: Int = 1) -> Delivery<T> {
        
        if maxCount < 1 {
            fatalError()
        }
        
        let arr = Array(repeating: self, count: maxCount)
        var temp = self
        for d in arr {
            temp = temp.catch({ (_) in
                return d
            })
        }
        return temp
    }

}





