//
//  TetrisAppDelegate.swift
//  Tetris
//
//  Created by 王俊仁 on 2018/5/3.
//

import Foundation


// MARK: - TetrisAppDelegate
open class TetrisAppDelegate : UIResponder, UIApplicationDelegate {
    open func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {

        XMidware.getModuler().trigger(AbstractModule.modulerInit)
        XMidware.getModuler().trigger(AbstractModule.modulerSetup)
        DispatchQueue.global().async {
            XMidware.getModuler().trigger(AbstractModule.modulerSplash)
        }
        return true
    }

    open func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        Context.shared.openURL = url
        Context.shared.openURLOptions = options
        XMidware.getModuler().trigger(AbstractModule.modulerHandleOpenURL_Options)
        return true
    }

    open func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        Context.shared.openURL = url
        XMidware.getModuler().trigger(AbstractModule.modulerHandleOpenURL)
        return true
    }

    open func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        Context.shared.openURL = url
        Context.shared.sourceApplication = sourceApplication
        Context.shared.annotation = annotation
        XMidware.getModuler().trigger(AbstractModule.modulerHandleOpenURL_SourceApplication_Annotation)
        return true
    }

    open func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        Context.shared.remoteNotificationItem.userInfo = userInfo
        XMidware.getModuler().trigger(AbstractModule.modulerDidReceiveRemoteNotification)
    }

    open func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Context.shared.remoteNotificationItem.failRegisterError = error
        XMidware.getModuler().trigger(AbstractModule.modulerDidRegisterRemoteNotification)
    }

    open func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        Context.shared.localNotification = notification
        XMidware.getModuler().trigger(AbstractModule.modulerDidReceiveLocalNotification)
    }

    open func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Context.shared.remoteNotificationItem.deviceToken = deviceToken
        XMidware.getModuler().trigger(AbstractModule.modulerDidRegisterRemoteNotification)
    }

}



