//
//  AppDelegate.swift
//  blecenter
//
//  Created by JOSN on 2018/1/28.
//  Copyright © 2018年 JOSN. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var bgTask: UIBackgroundTaskIdentifier!
    

    
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        
        
        //推播通知詢問
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
                if granted == false {
                    print("使用者未授權推播通知")
                }
                //            center.setNotificationCategories(setCategories())
            }
            center.delegate = self as? UNUserNotificationCenterDelegate
        } else {
            // Fallback on earlier versions
        }
        
        return true
    }


    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated .
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print("Into Backgroung")
        bgTask = application.beginBackgroundTask(expirationHandler: {
            print("Backgroung Timeup")
            application.endBackgroundTask(self.bgTask)
            self.bgTask = UIBackgroundTaskInvalid
        })
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background tothe active state; here you can undo many of the changes made on entering the background.
        print("Into Foreground")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

