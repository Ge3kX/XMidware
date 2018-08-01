//
//  Context.swift
//  Tetris
//
//  Created by 王俊仁 on 2018/5/3.
//

import Foundation


// MARK: - Context
public class Context {
    public static let shared = Context()
    private init() {}

    // MARK: application relate
    public private(set) var application = UIApplication.shared
    public private(set) var applicationDelegate = UIApplication.shared.delegate

    // MARK: launch relate
    public var launchOptions: [UIApplicationLaunchOptionsKey: Any]?

    // MARK: open url relate
    public var openURL: URL?
    public var sourceApplication: String?
    public var annotation: Any?
    public var openURLOptions: [UIApplicationOpenURLOptionsKey: Any]?

    // MARK: remote notification relate
    public var remoteNotificationItem = RemoteNotificationItem()

    // MARK: local notification relate
    public var localNotification: UILocalNotification?

}

public class RemoteNotificationItem {
    public var userInfo: [AnyHashable: Any]?
    public var failRegisterError: Error?
    public var deviceToken: Data?
}
