//
//  AppDelegate.swift
//  APICaller
//
//  Created by Ali Raza Amjad on 24/12/2019.
//  Copyright © 2019 Ali Raza. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        checkNetwork()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    //MARK: ReachbilityCheck
    //MARK:- Network
    private func checkNetwork() {
        setupReachability(useHostName: true, useClosures: false)
        GlobalBackgroundQueue.async {
            self.startNotifier()
        }
    }
    
    func setupReachability(useHostName: Bool, useClosures: Bool) {
        
        do {
            let reachability = try Reachability.reachabilityForInternetConnection()
            Utility.HelperFuntions.reachability = reachability
        } catch ReachabilityError.failedToCreateWithAddress(let address) {
            
            print("Unable to create\nReachability with address:\n\(address)")
            return
        } catch {}
        
        if (useClosures) {
            Utility.HelperFuntions.reachability?.whenReachable = { reachability in
                print("\(reachability.description) - \(reachability.currentReachabilityString)")
            }
            Utility.HelperFuntions.reachability?.whenUnreachable = { reachability in
                print("\(reachability.description) - \(reachability.currentReachabilityString)")
            }
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.reachabilityChanged(_:)), name: NSNotification.Name(rawValue: ReachabilityChangedNotification), object: Utility.HelperFuntions.reachability)
        }
    }
    
    func startNotifier() {
        print("--- start notifier")
        do {
            try Utility.HelperFuntions.reachability?.startNotifier()
        } catch {
            
            print("Unable to start\nnotifier")
            return
        }
    }
    
    func stopNotifier() {
        print("--- stop notifier")
        Utility.HelperFuntions.reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: ReachabilityChangedNotification), object: nil)
        Utility.HelperFuntions.reachability = nil
        Utility.HelperFuntions.connectionStatus = nil
    }
    
    @objc func reachabilityChanged(_ note: Notification) {
        let reachability = note.object as! Reachability
        
        if reachability.isReachable() {
            
            if reachability.isReachableViaWiFi() {
                
                print("Reachable via --------Wifi")
                networkReachableAlert()
                
            } else if reachability.isReachableViaWWAN(){
                
                print("Reachable via --------3G")
                networkReachableAlert()
                
            } else {
                
                print("Not Reachable via --------3G and Wifi")
                networkOutOfReachAlert()
            }
            
        } else {
            print("Not Reachable --------")
            networkOutOfReachAlert()
        }
    }
    
    fileprivate func networkReachableAlert() {
        hideKeyboard()
        Utility.HelperFuntions.connectionStatus = "reachable"
    }
    
    fileprivate func networkOutOfReachAlert() {
        hideKeyboard()
        Utility.HelperFuntions.connectionStatus = "notReachable"
    }
    
    fileprivate func hideKeyboard() {
        DispatchQueue.main.async { [unowned self] in
            if let rvc:UIViewController = self.window?.rootViewController {
                rvc.view.endEditing(true)
            } else if let rvc = UIApplication.shared.keyWindow?.rootViewController {
                if let nvc: UINavigationController = rvc as? UINavigationController {
                    let vc = nvc.viewControllers.last
                    vc?.view.endEditing(true)
                } else {
                    rvc.view.endEditing(true)
                }
            }
        }
    }
    
    deinit {
        stopNotifier()
    }
    
    //MARK: ProgressHUD
    func showProgessBar(_ view: UIView) {
        DispatchQueue.main.async {
            MBProgressHUD.showAdded(to: view, animated: false)
        }
    }
    
    func hideProgressBar(_ view: UIView) {
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: view, animated: true)
        }
    }
    
    
}

