//
//  AppDelegate.swift
//  SonarFirebase
//
//  Created by Brian Endo on 8/24/15.
//  Copyright (c) 2015 Brian Endo. All rights reserved.
//

import UIKit
import Firebase
import Parse

// Firebase url
let ref = Firebase(url: "https://sonarapp.firebaseio.com/")

// Global currentuser variable
var currentUser = ""

// Constants for Amazon Web Services
let CognitoRegionType = AWSRegionType.USEast1  // e.g. AWSRegionType.USEast1
let DefaultServiceRegionType = AWSRegionType.USWest1 // e.g. AWSRegionType.USEast1
let CognitoIdentityPoolId = "us-east-1:64427b0c-51a7-4d9a-9d8c-c5c8f5c2f8ea"
let S3BucketName = "sonarapp"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    

    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        UINavigationBar.appearance().translucent = false
        UINavigationBar.appearance().barTintColor = UIColor(red:0.28, green:0.27, blue:0.43, alpha:1.0)
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        // Parse Authentication
        Parse.setApplicationId("1ZnEzkEJJwfM15A9nwRBycra1ytofbfprHAGDLNa",
            clientKey: "9zMn4TYWHaJaUSGtRy2X9fxmgTDbT8trZsnQ08pl")
        
        // Check credentials for AWS
        let credentialsProvider = AWSCognitoCredentialsProvider(
            regionType: AWSRegionType.USEast1, identityPoolId: "us-east-1:64427b0c-51a7-4d9a-9d8c-c5c8f5c2f8ea")
        let defaultServiceConfiguration = AWSServiceConfiguration(
            region: AWSRegionType.USWest1, credentialsProvider: credentialsProvider)
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = defaultServiceConfiguration
        

        
        // Register for Push Notitications
        if application.applicationState != UIApplicationState.Background {
            // Track an app open here if we launch with a push, unless
            // "content_available" was used to trigger a background push (introduced in iOS 7).
            // In that case, we skip tracking here to avoid double counting the app-open.
            
            let preBackgroundPush = !application.respondsToSelector("backgroundRefreshStatus")
            let oldPushHandlerOnly = !self.respondsToSelector("application:didReceiveRemoteNotification:fetchCompletionHandler:")
            var pushPayload = false
            if let options = launchOptions {
                pushPayload = options[UIApplicationLaunchOptionsRemoteNotificationKey] != nil
            }
            if (preBackgroundPush || oldPushHandlerOnly || pushPayload) {
                PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
            }
        }
        if application.respondsToSelector("registerUserNotificationSettings:") {
            let userNotificationTypes = UIUserNotificationType.Alert | UIUserNotificationType.Badge | UIUserNotificationType.Sound
            let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        } else {
            let types = UIRemoteNotificationType.Badge | UIRemoteNotificationType.Alert | UIRemoteNotificationType.Sound
            application.registerForRemoteNotificationTypes(types)
        }
        
//        // Extract the notification data
//        if let notificationPayload = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? NSDictionary {
//            
//            // Create a pointer to the Photo object
//            let postId = notificationPayload["post"] as? String
//            println(postId)
//            let navigationController = UINavigationController()
//            let chatVC = ChatTableViewController()
//            chatVC.postID = postId
//            navigationController.pushViewController(chatVC, animated: true)
//            
//        }
        
        
        return true
    }
    
    func application(application: UIApplication, supportedInterfaceOrientationsForWindow window: UIWindow?) -> Int {
        
        if let currentVC = getCurrentViewController(self.window?.rootViewController){
            
            //VideoVC is the name of your class that should support landscape
            if currentVC is WebViewController{
                
                return Int(UIInterfaceOrientationMask.All.rawValue)
            }
        }
        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    }
    
    func getCurrentViewController(viewController:UIViewController?)-> UIViewController?{
        
        if let tabBarController = viewController as? UITabBarController{
            
            return getCurrentViewController(tabBarController.selectedViewController)
        }
        
        if let navigationController = viewController as? UINavigationController{
            return getCurrentViewController(navigationController.visibleViewController)
        }
        
        if let viewController = viewController?.presentedViewController {
            
            return getCurrentViewController(viewController)
            
        }else{
            
            return viewController
        }
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackground()
        
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010 {
            println("Push notifications are not supported in the iOS Simulator.")
        } else {
            println("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        if application.applicationState == UIApplicationState.Inactive {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
            if let postId = userInfo["post"] as? String {
                println(postId)
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
                let destinationViewController = storyboard.instantiateViewControllerWithIdentifier("ChatTableViewController") as! ChatTableViewController
                destinationViewController.postID = postId
                let navigationController = self.window?.rootViewController as! UINavigationController
                
                navigationController.pushViewController(destinationViewController, animated: true)
            }
        }
    }
    
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        let currentInstallation = PFInstallation.currentInstallation()
        if currentInstallation.badge != 0 {
            currentInstallation.badge = 0
            currentInstallation.saveEventually()
        }
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

