import Crashlytics
import FirebaseMessaging
import Foundation
import MyTBAKit
import UserNotifications

// PushService handles registering push notification tokens with TBA and handling APNS messages
// Has to be an NSObject subclass so we can be a UNUserNotificationCenterDelegate
class PushService: NSObject {

    private let backgroundService: BackgroundService
    private let myTBA: MyTBA

    private let operationQueue = OperationQueue()

    init(backgroundService: BackgroundService, myTBA: MyTBA) {
        self.backgroundService = backgroundService
        self.myTBA = myTBA
    }

    // TODO: Services like this maybe shouldn't contain their own operations queues, we should move them elsewhere?
    fileprivate func registerPushToken() {
        if !myTBA.isAuthenticated {
            // Not authenticated to myTBA - we'll try again when we're auth'd
            return
        }
        guard operationQueue.operationCount == 0 else {
            // Hack-y fix for register being called twice during app startup -
            // Once from MyTBAAuthenticationObservable.authenticated and once from
            // MessagingDelegate.didReceiveRegistrationToken
            // We should look to fix this properly some other time
            return
        }
        // TODO: We should make sure this ALWAYS ALWAYS completes
        let registerOperation = myTBA.register { (_, error) in
            if let error = error {
                self.backgroundService.scheduleRegisterPush()
                Crashlytics.sharedInstance().recordError(error)
            }
        }
        guard let op = registerOperation else { return }
        operationQueue.addOperation(op)
    }

    static func requestAuthorizationForNotifications(_ completion: ((Bool, Error?) -> Void)?) {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (granted, error) in
            completion?(granted, error)
        }
    }

    static func registerForRemoteNotifications(_ completion: ((Error?) -> ())?) {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Unable to get application delegate in PushService registerForRemoteNotifications")
        }

        delegate.registerForRemoteNotificationsCompletion = completion
        UIApplication.shared.registerForRemoteNotifications()
    }

}

extension PushService: MyTBAAuthenticationObservable {

    func authenticated() {
        registerPushToken()
    }

    func unauthenticated() {
        // TODO: Un-register shit with background task service?
    }
}

extension PushService: MessagingDelegate {

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        registerPushToken()
    }

    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("FCM Remote Data")
        print(remoteMessage.appData)
    }

}

extension PushService: UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Called when we're in the foreground and we recieve a notification
        // Show all notifications in the foreground
        print("Foreground push notification")
        print(notification.request.content.userInfo)
        completionHandler([.alert, .badge, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Called when we click a notification
        // TODO: Push to view controllers from notification
        let userInfo = response.notification.request.content.userInfo
        print("Push notification")
        print(userInfo)

        // Handle being launched from a push notification
        completionHandler()
    }

}
