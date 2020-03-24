//
//  NotificationService.swift
//  notificationServiceExtension
//
//  Created by Changyul Seo on 2020/02/24.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import UserNotifications
open class DownloadManager: NSObject {
    open class func image(_ URLString: String) -> String? {
        let componet = URLString.components(separatedBy: "/")
        if let fileName = componet.last {
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            if let documentsPath = paths.first {
                let filePath = documentsPath.appending("/" + fileName)
                if let imageURL = URL(string: URLString) {
                    do {
                        let data = try NSData(contentsOf: imageURL, options: NSData.ReadingOptions(rawValue: 0))
                        if data.write(toFile: filePath, atomically: true) {
                            return filePath
                        }
                    } catch {
                        print(error)
                    }
                }
            }
        }
        return nil
    }
}

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            // Modify the notification content here...
            //            bestAttemptContent.title = "\(bestAttemptContent.title) [modified]"
            let userInfo = bestAttemptContent.userInfo
            
            func downloadImage(imageURLString:String) {
                if let imagePath = DownloadManager.image(imageURLString) {
                    let imageURL = URL(fileURLWithPath: imagePath)
                    do {
                        let attach = try UNNotificationAttachment(identifier: "image-test", url: imageURL, options: nil)
                        bestAttemptContent.attachments = [attach,attach]
                    } catch {
                        print(error)
                    }
                }
            }
            
            print(bestAttemptContent.userInfo)
            if let fcmOptions = userInfo["fcm_options"] as? [String:String] {
                if let imageUrl = fcmOptions["image"] {
                    downloadImage(imageURLString: imageUrl)
                }
            }
            contentHandler(bestAttemptContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
