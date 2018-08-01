//
//  Displayer.swift
//  Tetris
//
//  Created by 王俊仁 on 2018/4/28.
//

import Foundation

public protocol IDisplayer {

    typealias Completion = () -> Void

    func display(from fromVC: UIViewController, to toVC: UIViewController, animated: Bool, complete: Completion?)

    func finishDisplay(_ vc: UIViewController, animated: Bool, complete: Completion?)

    func setNeedDisplay(_ vc: UIViewController, animated: Bool, complete: Completion?)
}



public extension IDisplayer {

    public func setNeedDisplay(_ vc: UIViewController, animated: Bool, complete: Completion?) {
        dismissTopViewControllers(vc, animated: animated) {
            _ = vc.navigationController?.ts.popToRootViewContoller(animated, completion: complete)
        }
    }

    func dismissTopViewControllers(_ vc: UIViewController, animated: Bool, completion: Completion?) {
        if let presented = vc.presentedViewController {
            dismissTopViewControllers(presented, animated: animated, completion: completion)
        }
        else if let completion = completion {
            completion()
        }
    }
}

open class PushPopDisplayer : IDisplayer {

    public init() {}

    open func finishDisplay(_ vc: UIViewController, animated: Bool, complete: IDisplayer.Completion?) {
        guard let nav = vc.navigationController else {
            return
        }

        if let idx = nav.viewControllers.index(of: vc), idx > 0 {
            let _ = nav.ts.popToViewController(nav.viewControllers[idx - 1], animated: animated, completion: complete)
        } else {
            let _ = nav.ts.popToRootViewContoller(animated, completion: complete)
        }
    }

    open func display(from fromVC: UIViewController, to toVC: UIViewController, animated: Bool, complete: IDisplayer.Completion?) {
        guard let nav = fromVC.navigationController else {
            return
        }

        let _ = nav.ts.pushViewController(toVC, animated: animated, completion: complete)
    }
}

open class PresentDismissDisplayer : IDisplayer {

    public init() {}

    open var source: UIViewController?

    open var navType: UINavigationController.Type = UINavigationController.self

    open func display(from fromVC: UIViewController, to toVC: UIViewController, animated: Bool, complete: IDisplayer.Completion?) {

        if let to = toVC as? UINavigationController {
            fromVC.present(to, animated: animated, completion: complete)
        } else {
            fromVC.present(navType.init(rootViewController: toVC), animated: animated, completion: complete)
        }

    }

    open func finishDisplay(_ vc: UIViewController, animated: Bool, complete: IDisplayer.Completion?) {
        (source ?? vc).dismiss(animated: animated, completion: complete)
    }


}


public extension Intent {
    public static func pushPop(url: URLPresentable? = nil, target: IntentTargetable.Type? = nil) -> Intent {
        let intent = Intent.init(url: try! url?.toURL(), target: target)
        intent.displayer = PushPopDisplayer()
        return intent
    }

    public static func presentDismiss(url: URLPresentable? = nil, target: IntentTargetable.Type? = nil) -> Intent {
        let intent = Intent.init(url: try! url?.toURL(), target: target)
        intent.displayer = PresentDismissDisplayer()
        return intent
    }
}
