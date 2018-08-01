//
//  UINavigationController+Completion.swift
//  Tetris
//
//  Created by 王俊仁 on 2018/4/28.
//


import Foundation

extension UIViewController : TetrisNamespacing {
}

extension _TetrisNamespaceWrapper where Subject : UINavigationController {

    private func executeWithCompletion(_ completion: IDisplayer.Completion?, animted: Bool) {
        if !animted {
            if let completion = completion {
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
        else if let completion = completion {
            subject.transitionCoordinator?.animate(alongsideTransition: nil, completion: { (contex) in
                completion()
            })
        }
    }

    public func setViewControllers(_ vcs: [UIViewController], animated: Bool = true, completion: IDisplayer.Completion? = nil) {
        subject.setViewControllers(vcs, animated: animated)
        executeWithCompletion(completion, animted: animated)
    }

    public func pushViewController(_ vc: UIViewController, animated: Bool = true, completion: IDisplayer.Completion? = nil) {
        subject.pushViewController(vc, animated: animated)
        executeWithCompletion(completion, animted: animated)
    }

    public func popViewController(_ animated: Bool = true, completion: IDisplayer.Completion? = nil) -> UIViewController? {
        let vc = subject.popViewController(animated: animated)
        executeWithCompletion(completion, animted: animated)
        return vc
    }

    public func popToViewController(_ vc: UIViewController, animated: Bool = true, completion: IDisplayer.Completion? = nil) -> [UIViewController]? {
        let vcs = subject.popToViewController(vc, animated: animated)
        executeWithCompletion(completion, animted: animated)
        return vcs
    }

    public func popToRootViewContoller(_ animated: Bool = true, completion: IDisplayer.Completion? = nil) -> [UIViewController]? {
        let vcs = subject.popToRootViewController(animated: animated)
        executeWithCompletion(completion, animted: animated)
        return vcs
    }
}


extension _TetrisNamespaceWrapper where Subject : UIViewController {

    public func _send<T>(result: T?, response code: Int = 0) {
        if let vc = subject as? Intentable {
            vc.sourceIntent?._send(result: result, response: code)
        }
    }

    public func _send<T>(signal: T?) {
        if let vc = subject as? Intentable {
            vc.sourceIntent?._send(signal: signal)
        }
    }

    public func finishDisplay(animated: Bool = true, complete: IDisplayer.Completion? = nil) {
        if let vc = subject as? (Intentable & UIViewController) {
            vc.sourceIntent?.displayer?.finishDisplay(vc, animated: animated, complete: complete)
        }
    }

    public func start(intent: Intent, complete: IDisplayer.Completion? = nil, finish: ((RouteResult) -> Void)? = nil) {
        getRouter().start(intent, source: subject, completion: complete) { finish?($0) }
    }

    public func prepare(_ intent: Intent, completion: IDisplayer.Completion? = nil) -> Delivery<RouteResult> {
        return getRouter().prepare(intent, source: subject, completion: completion)
    }

    public func navigate(_ url: URLPresentable?,
                         target: IntentTargetable.Type? = nil,
                         params: [String: Any]? = nil,
                         displayer: IDisplayer? = nil,
                         completion: IDisplayer.Completion? = nil) {


        print("error: you should pass a url or a intentable type!!!!")
        assert(url != nil || target != nil, "you should pass a url or a intentable type!!!!")

        let intent = Intent.pushPop(url: url, target: target)
        if let displayer = displayer {
            intent.displayer = displayer
        }
        subject.ts.start(intent: intent, complete: completion) { (_) in

        }

    }

}






