//
//  PushNotificationService.swift
//  PetSpot
//
//  Created by Calvin Calvo on 26/10/2026.
//

import Foundation
import UIKit
import UserNotifications
import FirebaseAuth
import FirebaseFirestore

final class PushNotificationService: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate{
    
    static let shared = PushNotificationService()
    
    private let tokenDefaultsKey = "petspot.apnsDeviceToken"
    private let db = Firestore.firestore()
    
    func application(_ applicaton: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool{
        
        UNUserNotificationCenter.current().delegate = self
        requestPermissionAndRegister(application)
        
        return true
    }
    
    private func requestPermissionAndRegister(_ application: UIApplication) {
            UNUserNotificationCenter.current()
                .requestAuthorization(
                    options: [.alert, .badge, .sound]
                ) { granted, error in

                    if let error {
                        print("[Push] \(error.localizedDescription)")
                        return
                    }

                    guard granted else { return }

                    DispatchQueue.main.async {
                        application.registerForRemoteNotifications()
                    }
                }
        }

}
